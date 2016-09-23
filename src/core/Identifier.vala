using Ricin;

public class Ricin.Identifier : Object {
  /**
  * The public key of the identifier.
  **/
  private string public_key { get; protected set; default = ""; }
  
  /**
  * The nospam value of the identifier.
  **/
  private string nospam { get; protected set; default = ""; }
  
  /**
  * The checksum value that permits to verify the ToxID integrity.
  **/
  private string checksum { get; protected set; default = ""; }

  /**
  * The identifier constructor.
  * @param {string} key - A string containing or a full toxid, or a public key.
  **/
  public Identifier (string key) {
    /**
    * TODO: use `key` to fill the public_key, nospam and checksum.
    **/
  }
  
  /**
  * This method returns the complete toxid, if available.
  **/
  public string get_toxid () {
    return this.public_key + this.nospam + this.checksum;
  }
  
  /**
  * This method returns the public key.
  **/
  public string get_pubkey_value () {
    return this.public_key;
  }
  
  /**
  * This method returns the nospam.
  **/
  public string get_nospam_value () {
    return this.nospam;
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
  * This method return the checksum.
  **/
  public string get_checksum_value () {
    return this.checksum;
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

