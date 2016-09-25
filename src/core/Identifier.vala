using Ricin;

public class Ricin.Identifier : Object {
  /**
  * The public key of the identifier.
  **/
  public string public_key { get; protected set; default = ""; }
  
  /**
  * The nospam value of the identifier.
  **/
  public string? nospam { get; protected set; default = null; }
  
  /**
  * The checksum value that permits to verify the ToxID integrity.
  **/
  public string? checksum { get; protected set; default = null; }

  /**
  * The identifier constructor.
  * @param {string} key - A string containing or a full toxid, or a public key.
  **/
  public Identifier (string key) {
    if (key.length == ToxCore.PUBLIC_KEY_SIZE) { // In key is a public key (no nospam/checksum).
      this.public_key = key;
    } else if (key.length == ToxCore.ADDRESS_SIZE) { // If key is a ToxID.
      this.public_key = key.slice (0, ToxCore.PUBLIC_KEY_SIZE);
      this.nospam = key.slice (ToxCore.PUBLIC_KEY_SIZE, Constants.NOSPAM_SIZE);
      this.checksum = key.slice (ToxCore.PUBLIC_KEY_SIZE + Constants.NOSPAM_SIZE, Constants.CHECKSUM_SIZE);
    } else if (key.length == ToxCore.PUBLIC_KEY_SIZE + Constants.NOSPAM_SIZE) { // Pubkey + nospam but no checksum.
      this.public_key = key.slice (0, ToxCore.PUBLIC_KEY_SIZE);
      this.nospam = key.slice (ToxCore.PUBLIC_KEY_SIZE, Constants.NOSPAM_SIZE);
    }
  }
  
  /**
  * This method returns the complete toxid, if available.
  **/
  public string get_toxid () {
    return this.public_key + this.nospam + this.checksum;
  }
  
  /**
  * This method permits to randomly change the nospam both in the identifier and in toxcore save.
  **/
  public string randomize_nospam () {
    /**
    * TODO: Write code to randomize a nospam and trigger the ToxSession signal to change it.
    **/
    return ""; // Temp code, see TODO.
  }
  
  /**
  * This method permits to compute the checksum with a public_key + a nospam.
  * @param {bool} fill - If set to true, this.checksum will take the computed value.
  **/
  public string compute_checksum (bool fill = false) {
    /**
    * TODO: Compute the checksum using this.public_key and this.nospam.
    **/
  
    if (fill) {
      /**
      * TODO: Store the previously computed value in this.checksum.
      **/
    }
    
    return ""; // Temp code, see TODOs.
  }
}

