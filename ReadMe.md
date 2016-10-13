# Ricin - A dead simple, privacy oriented, instant messaging client!

[![Ricin license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://raw.githubusercontent.com/RicinApp/Ricin/rewrite-clean/LICENSE)
[![Ricin release](https://img.shields.io/github/release/RicinApp/Ricin.svg?style=flat)](https://github.com/RicinApp/Ricin/releases/latest)
[![Ricin open issues](https://img.shields.io/github/issues/RicinApp/Ricin.svg?style=flat)](https://github.com/RicinApp/Ricin/issues)
[![Codecov rewrite-clean](https://img.shields.io/codecov/c/github/RicinApp/Ricin/rewrite-clean.svg?style=flat)](https://codecov.io/github/RicinApp/Ricin)
[![TravisCI](https://img.shields.io/travis/RicinApp/Ricin/rewrite-clean.svg?style=flat)](https://travis-ci.org/RicinApp/Ricin)

Ricin aims to be a modern way to securly communicate with people that matters in your life.  
Ricin is using the Tox protocol to perform P2P encrypted instant messaging, file transfers, audio/video calls, etc.

This is a complete rewrite of the current code, which is an evil shit. I hope this time i'll be able to do things right.

##### If you are looking for the current version of Ricin, [here you go](https://github.com/RicinApp/Ricin/tree/master).

# Roadmap
* Properly abstract things using interfaces ;
* Write class with only the needed methods/properties, not more not less ;
* Write proper documentation, every method/property/signal **MUST** be documented ;
* Setup a clean build system and integrations (CI, Code coverage, tests) ;
* Write tests to ensure everything works properly ;
* Once all these steps are done correctly, start working on the GUI ;
* Connect the GUI signals to the proper methods/signals ;
* Setup an OBS repository and make a `.spec` file to have Ricin packaged everywhere ;
* Dominate the world!

# Compile the beast!
In order to compile Ricin you'll need some dependencies, instead of loosing time to maintain a list here,
I'll thanks you to read the [wscript](wscript#L25) file that currently takes care of dependencies hell.

Once you have all the dependencies (at least the one marked as mandatory), you should be able to build
Ricin using the following commands under linux/bsd (i'll provide OSX/Windoesn't commands later):

```bash
# Ensure you are in the correct directory (the one you just cloned) then:
./waf configure build

# Now run it!
./build/ricin --version
```

# Donations
Rewriting my client with a top-notch code will be long and hard, but I know I can do it.  
Anyway, hope is not a way to live and I need to stay on my computer for writing code, so I can't work on anything else,
while rewriting Ricin.

That's why I wrote this statement, donations are not always about money, you can also donate me some love, feedbacks,
report the bugs you've seen, contribute to the code, pay me a bear (wuups, a beer, eheh).

Of course if you really wish to give me some money for that work, i won't reject it. But before donating money, ask
yourself "Do he really merits that money? Do I believe in privacy enough to give some cents to this crazy guy?". If you
can answer both by **yes**, then here are how you can make a donation:

###### Bitcoin
Yep, Bitcoin is my favourite way of handling donations. Why? Cuz their is no fees, no central authority, no bullshit taxes.

* Here's my Bitcoin donation address: **16NAwHmK9HwqJzgbpsNgjpsHE18Z8rvFsv**

###### Patreon
You can also become my boss and pay me to develop things you'd like to see in Ricin !

* Here's my Patreon page: [SkyzohKey on Patreon](https://www.patreon.com/user?u=2330345)

# License
Ricin source code is released under [The MIT License](LICENSE).
