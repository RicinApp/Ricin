using Gdk;
using ToxEncrypt;
using Ricin;
using Ricin.Utils;
using Ricin.Core;

namespace Ricin.Core {
  public class Profile : IPerson, Object {
    /**
    * A reference to the ToxCore instance object.
    **/
    private weak ToxCore.Tox handle;

    /**
    * The profile tox data.
    **/
    private uint8[] savedata { get; internal set; }

    /**
    * Is the profile an encrypted profile ?
    **/
    public bool is_profile_encrypted { get; set; default = false; }

    /**
    * The person ToxID. Identifier class allows to get nospam, checksum, etc more easily.
    **/
    public Identifier? id { get; internal set; default = null; }

    /**
    * The profile path.
    **/
    public string path { get; internal set; default = ""; }

    /**
    * The person name.
    **/
    public string name {
      owned get {
        size_t buffer_size = this.handle.self_get_name_size ();
        uint8[] buffer = new uint8[buffer_size];
        this.handle.self_get_name (buffer);

        string _name = Utils.Helpers.arr2str (buffer);
        if (_name == "") {
          return Constants.DEFAULT_NAME;
        } else {
          return _name;
        }
      }
      set {
        this.handle.self_set_name (value.data, null);

        try {
          this.save_data (); // Let's save once name changes.
        } catch (ErrDecrypt e) {
          debug ("P: Cannot save new name in tox save, error: $(e.message)");
        }
      }
    }

    /**
    * The person status message.
    **/
    public string status_message {
      owned get {
        size_t buffer_size = this.handle.self_get_status_message_size ();
        uint8[] buffer = new uint8[buffer_size];
        this.handle.self_get_status_message (buffer);

        string _status_message = Utils.Helpers.arr2str (buffer);
        if (_status_message == "") {
          return Constants.DEFAULT_STATUS_MESSAGE;
        } else {
          return _status_message;
        }
      }
      set {
        this.handle.self_set_status_message (value.data, null);

        try {
          this.save_data (); // Let's save once status message changes.
        } catch (ErrDecrypt e) {
          debug ("P: Cannot save new status message in tox save, error: $(e.message)");
        }
      }
    }

    /**
    * The person presence status.
    **/
    public Presence status { get; set; default = Presence.OFFLINE; }

    /**
    * The person avatar as a Pixbuf.
    **/
    public Pixbuf? avatar { get; set; default = null; }

    /**
    * A simple boolean to indicate whether or not the profile has been loaded.
    **/
    public bool loaded { get; internal set; default = false; }

    /**
    * The profile password, private and only used to encrypt the profile when it needs to be written on the disk.
    **/
    private string? password { get; set; default = null; }

    /**
    * This constructor permits to load an existing profile.
    * @param {ToxCore.Tox} handle - A reference to the toxcore instance.
    * @param {string} path - The profile path.
    * @param {string?} password - The profile path if any, can be null for not-protected profiles.
    **/
    public Profile (ToxCore.Tox handle, string path, string? password = null) {
      this.handle = handle;
      this.path = path;
      this.password = password;

      try {
        this.load_data ();
      } catch (ErrDecrypt e) {
        error (@"P: Cannot load the profile at `$(this.path)`, error: $(e.message)");
      }

      this.init_signals ();
    }

    /**
    * This constructor permits to create a new profile.
    * @param {string} name - The profile name (will be used both as a filename and username).
    * @param {string} password - The profile encryption password. If null, profile won't be encrypted.
    **/
    public Profile.create (string name, string? password = null) {
      /**
      * TODO: Create the .tox file for this new profile.
      * TODO: Set the profile name to `name`.
      * TODO: Save the default Tox state inside the newly created file.
      * TODO: If password is not null, encrypt the profile and mark the profile as encrypted.
      * TODO: Call this.load_data().
      **/
    }

    /**
    * Init some profile specific signals.
    **/
    private void init_signals () {

    }

    /**
    * This method uses ToxEncrypt to determine whether or not the profile is encrypted.
    * @return {bool} - Returns true if the profile is encrypted, false if not.
    **/
    public bool is_encrypted () {
      if (this.loaded == false) return false;

      if (this.is_profile_encrypted == false) {
        return ToxEncrypt.is_data_encrypted (this.savedata);
      } else {
        return this.is_profile_encrypted;
      }
    }

    /**
    * This method permits to load the profile data into this class.
    **/
    public void load_data () throws ErrDecrypt {
      try {
        if (FileUtils.test (this.path, FileTest.EXISTS)) {
          uint8[] buffer = null;
          FileUtils.get_data (this.path, out buffer);
          this.savedata = buffer;

          if (this.is_encrypted ()) { // Handle encrypted profiles.
            this.is_profile_encrypted = true;

            ERR_DECRYPTION error;
            uint8[] password = this.password.data;

            int data_size = buffer.length - ToxEncrypt.PASS_ENCRYPTION_EXTRA_LENGTH;
            uint8[] decrypted_buffer = new uint8[data_size];

            ToxEncrypt.pass_decrypt (buffer, password, decrypted_buffer, out error);

            if (error != ERR_DECRYPTION.OK) {
              switch (error) {
                case ERR_DECRYPTION.NULL:
                  throw new ErrDecrypt.Null ("Some input data, or maybe the output pointer, was null.");
                case ERR_DECRYPTION.INVALID_LENGTH:
                  throw new ErrDecrypt.InvalidLength ("The input data was shorter than TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes.");
                case ERR_DECRYPTION.BAD_FORMAT:
                  throw new ErrDecrypt.BadFormat ("The input data is missing the magic number (i.e. wasn't created by this module, or is corrupted).");
                case ERR_DECRYPTION.KEY_DERIVATION_FAILED:
                  throw new ErrDecrypt.KeyDerivationFailed ("The crypto lib was unable to derive a key from the given passphrase, which is usually a lack of memory issue. The functions accepting keys do not produce this error.");
                case ERR_DECRYPTION.FAILED:
                  throw new ErrDecrypt.Failed ("The encrypted byte array could not be decrypted. Either the data was corrupt or the password/key was incorrect.");
              }
            }

            this.savedata = decrypted_buffer; // Let's store the new decrypted data into this.
          }

          this.loaded = true;
        } else {
          /**
          * TODO: Throw ErrProfile.DONT_EXISTS *OR* create the profile and load it.
          **/
        }
      } catch (Error e) {
        debug (@"P: Cannot load profile, error: $(e.message)");
      }
    }

    /**
    * This method permits to save the profile data from this class to the .tox save.
    **/
    public void save_data () throws ErrDecrypt {
      debug (@"P: Saving profile to Tox save for $(this.name) profile.");
      uint32 data_size = this.handle.get_savedata_size ();
      uint8[] buffer = new uint8[data_size];
      this.handle.get_savedata (buffer);

      try {
        if (FileUtils.test (this.path, FileTest.EXISTS)) {
          if (this.is_encrypted ()) { // Handle encrypted profiles.
            ERR_ENCRYPTION error;
            uint8[] password = this.password.data;

            this.handle.get_savedata (buffer);

            uint32 savedata_size = buffer.length + ToxEncrypt.PASS_ENCRYPTION_EXTRA_LENGTH;
            uint8[] encrypted_buffer = new uint8[savedata_size];

            ToxEncrypt.pass_encrypt (buffer, password, encrypted_buffer, out error);

            if (error != ERR_ENCRYPTION.OK) {
              switch (error) {
                case ERR_ENCRYPTION.NULL:
                  throw new ErrDecrypt.Null ("Some input data, or maybe the output pointer, was null.");
                case ERR_ENCRYPTION.KEY_DERIVATION_FAILED:
                  throw new ErrDecrypt.KeyDerivationFailed ("The crypto lib was unable to derive a key from the given passphrase, which is usually a lack of memory issue. The functions accepting keys do not produce this error.");
                case ERR_ENCRYPTION.FAILED:
                  throw new ErrDecrypt.Failed ("The encryption itself failed.");
              }
            }

            FileUtils.set_data (this.path, encrypted_buffer);
          } else {
            FileUtils.set_data (this.path, buffer);
          }
        } else {
          /**
          * TODO: Create file at `this.path` and call this.save_data() again.
          **/
        }
      } catch (Error e) {
        debug (@"P: Cannot save profile, error: $(e.message)");
      }
    }
  }
}
