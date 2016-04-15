[CCode (cheader_filename="toxencryptsave/toxencryptsave.h", cprefix="Tox", lower_case_cprefix="tox_")]
namespace ToxEncrypt {
  public const uint32 PASS_SALT_LENGTH;
  public const uint32 PASS_KEY_LENGTH;
  public const int PASS_ENCRYPTION_EXTRA_LENGTH;

  [CCode (cname="TOX_PASS_KEY", has_type_id=false)]
  [Compact]
  public class PassKey {
    [CCode (array_length=false, array_length_cexpr="TOX_PASS_SALT_LENGTH")] uint8[] salt;
    [CCode (array_length=false, array_length_cexpr="TOX_PASS_KEY_LENGTH")] uint8[] key;
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
  * TODO: Make a proper doc for these functions.
  */

  public static bool pass_encrypt ([CCode (array_length_type="size_t")] uint8[] data, [CCode (array_length_type="size_t")] uint8[] passphrase, [CCode (array_length=false)] uint8[] @out, out ERR_ENCRYPTION error);

  public static bool pass_decrypt ([CCode (array_length_type="size_t")] uint8[] data, [CCode (array_length_type="size_t")] uint8[] passphrase, [CCode (array_length=false)] uint8[] @out, out ERR_DECRYPTION error);

  public static bool derive_key_from_pass ([CCode (array_length_type="size_t")] uint8[] passphrase, out PassKey out_key, out ERR_KEY_DERIVATION error);

  public static bool derive_key_with_salt ([CCode (array_length_type="size_t")] uint8[] passphrase, [CCode (array_length=false)] uint8 salt, out PassKey out_key, out ERR_KEY_DERIVATION error);

  public static bool get_salt ([CCode (array_length_type="size_t")] uint8[] data, out uint8 salt);

  public static bool pass_key_encrypt ([CCode (array_length_type="size_t")] uint8[] data, PassKey key, [CCode (array_length=false)] uint8 @out, out ERR_DECRYPTION error);

  public static bool pass_key_decrypt ([CCode (array_length_type="size_t")] uint8[] data, PassKey key, [CCode (array_length=false)] uint8 @out, out ERR_DECRYPTION error);

  public static bool is_data_encrypted (uint8[] data);
}
