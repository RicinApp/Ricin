using Ricin;
using Ricin.Core;

namespace Ricin.Core {
  public class ToxDhtNode : Object {
    /**
    * The DHT Node owner/maintainer name.
    **/
    public string owner { get; set; }

    /**
    * The DHT Node location (2 letter code)
    **/
    public string region { get; set; }

    /**
    * The DHT Node IPv4, can be null.
    **/
    public string ipv4 { get; set; }

    /**
    * The DHT Node IPv6, can be null.
    **/
    public string ipv6 { get; set; }

    /**
    * The DHT Node port.
    **/
    public uint64 port { get; set; }

    /**
    * The DHT Node public key, used by toxcore to verify integrity and avoid MITM.
    **/
    public string pubkey { get; set; }
  }
}
