using ToxCore;
using Ricin;
using Ricin.Utils;
using Ricin.Core;

namespace Ricin.Core {
  public class ToxOptions : Object {
    /**
    * This method permits to copy a ToxCore.Options object.
    * @param {ToxCore.Options} opts - The Options object to copy from.
    * @return {ToxCore.Options} - Returns a newly created Options object.
    **/
    public static Options copy (Options opts) {
      var options = ToxOptions.create ();

      // That's ugly but this is the only way to achieve copy.
      options.ipv6_enabled = opts.ipv6_enabled;
      options.udp_enabled = opts.udp_enabled;
      options.proxy_type = opts.proxy_type;
      options.proxy_host = opts.proxy_host;
      options.proxy_port = opts.proxy_port;
      options.start_port = opts.start_port;
      options.tcp_port = opts.tcp_port;
      options.savedata_type = opts.savedata_type;
      options.savedata_data = opts.savedata_data;

      return options;
    }

    /**
    * This method permits to create a default ToxCore.Options object.
    * @return {ToxCore.Options} - Returns a newly default created Options object.
    **/
    public static Options create () {
      return new Options (null);
    }
  }
}
