[CCode (cheader_filename="tox/toxencryptsave.h", cprefix="Tox", lower_case_cprefix="tox_")]
namespace ToxEncrypt {
  public const uint32 PASS_SALT_LENGTH;
  public const uint32 PASS_KEY_LENGTH;
  public const int PASS_ENCRYPTION_EXTRA_LENGTH;

  /**
   * This key structure's internals should not be used by any client program, even
   * if they are straightforward here.
   */
   [CCode (cname="struct TOX_PASS_KEY", destroy_function="", has_type_id=false)]
   [Compact]
   public class PassKey {
     [CCode (array_length=false, array_length_cexpr="TOX_PASS_SALT_LENGTH")]
     public uint8[] salt;
     [CCode (array_length=false, array_length_cexpr="TOX_PASS_KEY_LENGTH")]
     public uint8[] key;

     public PassKey ();
   }


  /*******************************************************************************
   *
   * :: Errors enums
   *
   ******************************************************************************/
  [CCode (cname="TOX_ERR_KEY_DERIVATION", cprefix="TOX_ERR_KEY_DERIVATION_")]
  public enum ERR_KEY_DERIVATION {
    OK,
    /**
     * Some input data, or maybe the output pointer, was null.
     */
    NULL,
    /**
     * The crypto lib was unable to derive a key from the given passphrase,
     * which is usually a lack of memory issue. The functions accepting keys
     * do not produce this error.
     */
    FAILED
  }

  [CCode (cname="TOX_ERR_ENCRYPTION", cprefix="TOX_ERR_ENCRYPTION_")]
  public enum ERR_ENCRYPTION {
    OK,
    /**
     * Some input data, or maybe the output pointer, was null.
     */
    NULL,
    /**
     * The crypto lib was unable to derive a key from the given passphrase,
     * which is usually a lack of memory issue. The functions accepting keys
     * do not produce this error.
     */
    KEY_DERIVATION_FAILED,
    /**
     * The encryption itself failed.
     */
    FAILED
  }

  [CCode (cname="TOX_ERR_DECRYPTION", cprefix="TOX_ERR_DECRYPTION_")]
  public enum ERR_DECRYPTION {
    OK,
    /**
     * Some input data, or maybe the output pointer, was null.
     */
    NULL,
    /**
     * The input data was shorter than TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes
     */
    INVALID_LENGTH,
    /**
     * The input data is missing the magic number (i.e. wasn't created by this
     * module, or is corrupted)
     */
    BAD_FORMAT,
    /**
     * The crypto lib was unable to derive a key from the given passphrase,
     * which is usually a lack of memory issue. The functions accepting keys
     * do not produce this error.
     */
    KEY_DERIVATION_FAILED,
    /**
     * The encrypted byte array could not be decrypted. Either the data was
     * corrupt or the password/key was incorrect.
     */
    FAILED
  }

  /**
   * Encrypts the given data with the given passphrase. The output array must be
   * at least data_len + TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes long. This delegates
   * to tox_derive_key_from_pass and tox_pass_key_encrypt.
   *
   * returns true on success
   */
  public static bool pass_encrypt (
    [CCode (array_length_type="size_t")] uint8[] data,
    [CCode (array_length_type="size_t")] uint8[] passphrase,
    [CCode (array_length=false)] out uint8[] @out,
    out ERR_ENCRYPTION error
  );

  /**
   * Decrypts the given data with the given passphrase. The output array must be
   * at least data_len - TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes long. This delegates
   * to tox_pass_key_decrypt.
   *
   * the output data has size data_length - TOX_PASS_ENCRYPTION_EXTRA_LENGTH
   *
   * returns true on success
   */
  public static bool pass_decrypt (
    [CCode (array_length_type="size_t")] uint8[] data,
    [CCode (array_length_type="size_t")] uint8[] passphrase,
    [CCode (array_length=false)] out uint8[] @out,
    out ERR_DECRYPTION error
  );

  /**
   * Generates a secret symmetric key from the given passphrase. out_key must be at least
   * TOX_PASS_KEY_LENGTH bytes long.
   * Be sure to not compromise the key! Only keep it in memory, do not write to disk.
   * The password is zeroed after key derivation.
   * The key should only be used with the other functions in this module, as it
   * includes a salt.
   * Note that this function is not deterministic; to derive the same key from a
   * password, you also must know the random salt that was used. See below.
   *
   * returns true on success
   */
  public static bool derive_key_from_pass (
    [CCode (array_length_type="size_t")] uint8[] passphrase,
    out PassKey out_key, out ERR_KEY_DERIVATION error
  );

  /**
   * Same as derive_key_from_pass, except use the given salt for deterministic key derivation.
   * The salt must be TOX_PASS_SALT_LENGTH bytes in length.
   */
  public static bool derive_key_with_salt (
    [CCode (array_length_type="size_t")] uint8[] passphrase,
    [CCode (array_length=false)] uint8[] salt,
    out PassKey out_key, out ERR_KEY_DERIVATION error
  );

  /**
   * This retrieves the salt used to encrypt the given data, which can then be passed to
   * derive_key_with_salt to produce the same key as was previously used. Any encrpyted
   * data with this module can be used as input.
   *
   * returns true if magic number matches
   * success does not say anything about the validity of the data, only that data of
   * the appropriate size was copied
   */
  public static bool get_salt (
    [CCode (array_length=false)] uint8[] data,
    [CCode (array_length=false)] out uint8[] salt
  );

  /**
   * Encrypt arbitrary with a key produced by tox_derive_key_*. The output
   * array must be at least data_len + TOX_PASS_ENCRYPTION_EXTRA_LENGTH bytes long.
   * key must be TOX_PASS_KEY_LENGTH bytes.
   * If you already have a symmetric key from somewhere besides this module, simply
   * call encrypt_data_symmetric in toxcore/crypto_core directly.
   *
   * returns true on success
   */
  public static bool pass_key_encrypt (
    [CCode (array_length_type="size_t")] uint8[] data,
    PassKey key,
    [CCode (array_length=false)] out uint8 @out,
    out ERR_DECRYPTION error
  );


  /**
   * This is the inverse of tox_pass_key_encrypt, also using only keys produced by
   * tox_derive_key_from_pass.
   *
   * the output data has size data_length - TOX_PASS_ENCRYPTION_EXTRA_LENGTH
   *
   * returns true on success
   */
  public static bool pass_key_decrypt ([CCode (array_length_type="size_t")] uint8[] data, PassKey key, [CCode (array_length=false)] out uint8[] @out, out ERR_DECRYPTION error);

  /**
   * Determines whether or not the given data is encrypted (by checking the magic number)
   */
  public static bool is_data_encrypted ([CCode (array_length=false)] uint8[] data);
}
