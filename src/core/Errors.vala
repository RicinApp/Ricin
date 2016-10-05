using Ricin;
using Ricin.Core;

/**
* TODO: Documentation for each errordomain.
* TODO: Documentation for every error.
**/

namespace Ricin.Core {
  public errordomain ErrNew {
    Null,
    Malloc,
    PortAlloc,
    BadProxy,
    LoadFailed
  }

  public errordomain ErrDecrypt {
    Null,
    InvalidLength,
    BadFormat,
    KeyDerivationFailed,
    Failed
  }

  public errordomain ErrFriendAdd {
    Null,
    TooLong,
    NoMessage,
    OwnKey,
    AlreadySent,
    BadChecksum,
    BadNospam,
    Malloc
  }

  public errordomain ErrFriendDelete {
    NotFound
  }
}
