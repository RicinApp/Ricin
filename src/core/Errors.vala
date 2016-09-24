/**
* TODO: Documentation for each errordomain.
* TODO: Documentation for every error.
**/

public errordomain Ricin.ErrNew {
  Null,
  Malloc,
  PortAlloc,
  BadProxy,
  LoadFailed
}

public errordomain Ricin.ErrDecrypt {
  Null,
  InvalidLength,
  BadFormat,
  KeyDerivationFailed,
  Failed
}

public errordomain Ricin.ErrFriendAdd {
  Null,
  TooLong,
  NoMessage,
  OwnKey,
  AlreadySent,
  BadChecksum,
  BadNospam,
  Malloc
}

public errordomain Ricin.ErrFriendDelete {
  NotFound
}
