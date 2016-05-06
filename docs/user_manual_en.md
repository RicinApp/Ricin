# Ricin user guide

## Table of contents
- [Introduction]
  1. [Basic Tox concepts]
  2. [Definition table]
- [Create a profile]
- [Customize your profile]
  1. [Name]
  2. [Status message]
  3. [Avatar]
  4. [Status] - online, away, busy
- [Add a friend]
  1. [using a ToxID]
  2. [using a Public Key]
- [Manage your friend list]
  1. [Accept/Reject a friend request]
  2. [Delete a friend]
  3. [Block a friend]
  4. [Copy friend's Public Key]
  5. [Add notes about a friend]
- [Talk with a friend]
  1. [Basic messages]
  2. [Quotes]
  3. [Markdown] - text formatting
- [Send a file]
  1. [Inline images]
  2. [Others files]
- [Customize Ricin: Settings]
  - [General tab]
    1. [Get your ToxID]
    2. [Change your nospam]
    3. [Choose a default save path]
  - [Network tab]
    1. [Configure the connection method: UDP or TCP]
    2. [Configure a SOCKS5 proxy]
  - [Interface tab]
    1. [Themes system]
    2. [Choose a language]
    3. [Configure the Ricin interface]
    
## Introduction
**Ricin** aims to be a popular instant messaging client for the Tox network. We built it in order to offer the most intuitive and performing talk app. The point of Ricin is to provide the highest quality when chatting with your friends, contacts, employees, and other people that matters in your life.

This guide aims to explain all the features of Ricin in details meaning you cannot be lost in the Ricin interface. In case of doubt, just read the manual.

### Basic Tox concepts
In this subsections, let's describe and define the main points of Tox, what is it? How does it works? What makes it better than Skype? All of these questions are answered bellow.

Tox aims to bring privacy in a world where every moves you do are recorded in big databases by some stupid companies (NSA, to only cite this one).

To achieve this Tox is P2P based (as a distributed network), which means that any one that joins the network permits it to live. It also means that Tox cannot been shutdown, by nobody.

**Warning**: Tox is **NOT** anonymizing your connection, if you want to be anonymous while using Ricin, simply [Configure a SOCKS5 proxy] to your local Tor proxy.

Tox won't distributed/leak your IP you didn't decided it. Only people you accepted as friend (and as such, that you trust) can receive your IP. Their is no other way to obtain your computer address.

Here introduce the ToxID concept. A ToxID is a suit of 76 random chars that permits to "identify" you as a Tox user.  
This ToxID is composed of a **Public Key** (64 chars), a **nospam** (6 chars) and a **checksum** (4 chars). Nospam is a value intended to protect you from people spamming with friend requests. Once you [Change your nospam] a part of your ToxID changes, invalidating the old one. The Checksum is a simple value that permits to verify the integrity of a ToxID.

### Definition table
<span id="dt-profile-name"></span>
- Profile name: Not an username, this is only your `.tox` file name.

**TODO:** Add definitions here as I write the manual.

## Create a profile
The first time you launch Ricin, if you never used Tox before, you'll have to create a profile. A profile is a single `.tox` file that contains your name, your status message, your friends list, etc. This file **must not** be modified by hand, only Ricin (or another Tox client) should write in it. Editing this file by hand *may* expose you to profile corruption.

In order to create a profile, simply start Ricin and select the "Create a profile" tab in the top right. Enter your [profile name] then click "Create". Ricin will create the profile and open the main window.

![Creating a profile within Ricin](https://i.imgur.com/cmguEeK.png)

## Customize your profile
Ricin is built as you can customize pretty much everything, let's talk about your profile! The top left area is where you can personalize how you appears on your friends screen.

![The profile area in Ricin](https://i.imgur.com/XFwycIh.png)

### Name
Your name is what your friends see first when they search for you. It can be a nickname or a real name, nothing too long as on little screens your name may appears ellipsised if too long. Choose something that represents you. Something that permits your contacts to know who you are.

Their is no limitations or artificial caps on names, you can leave it blank, add emojis, Chinese, Hebrew, and even Unicode but *please*, don't.

### Status message
The status message is something you can use to share whatever you want ; your mood, your favorite song, a link you want to share, a meeting date, etc. That's a **public** data that all of your friends are able to read whenever they want.

Same as names, their is no limitations or artificial caps on status messages. Feel creatives!

### Avatar
An avatar is a picture that represents you, it permits your friends to identify you in a eye regard. That's a sort of virtual representation of you. You can use any avatar you want.

Unlike name and status messages, avatars are submitted to some limitations. Nothing too restricting.

- Avatars **should** be lower than 64 Ko, size isn't checked but a weightier avatar is faster to download.
- Avatars preferred dimensions are `100x100px`. Any bigger image may be scaled down and lose it's visibility.
- Avatars file type **allowed** are: `.png`, `.jpg`, `.jpeg`, `.svg`  
  (Note that SVG are only supported by Ricin, not by the other Tox clients).

To change your avatar, simply click it. It's a square located at the **top left** of the main window.

### Status
Your status indicate whenever you are online, busy, away or offline.  
**Note**: In busy mode, notifications are disabled in order to not disturb you.

Status is cycled in the following order: Online, Away, Busy.  
Changing your status is simple as clicking on it.

## Add a friend
As an instant messaging application, you probably want to add friends to your friends list. That's better in order to talk. Adding peoples in Tox can be done using 2 methods. Let's describe and compare them.

![Button to open the add friend dialog](https://i.imgur.com/AMsaTcf.png)  
*You can add a friend by clicking the button at the **bottom left** of the main window.*

![Adding a friend on Ricin](https://i.imgur.com/eYvjIEN.png)

### Using a ToxID
That's probably the most convenient way to add a friend. Your friend sends you it's ToxID and you just have to paste it in the "Add friend dialog" (see above) then choose a message that will join the friend request. Once you send the request, your friend will receive it and have the choice to **accept** or **reject** it. If it reject the friend request, you'll never see it online. Else, it will simply appears in your friends list.

### Using a Public Key
The other way to add a friend is by only knowing it's Public Key. The difference with [using a ToxID] is that this method **doesn't** send a friend request. This can be useful in case you don't want Tox to know that you added this friend.

**Note**: This way requires both you and your friend to add your Public Keys/ToxID mutually.
**Note2**: This way will simply write the friend in your `.tox` profile and lookup for your friend's IP.

[TABLE OF CONTENTS]: ####

[Introduction]: #Introduction
[Basic Tox concepts]: #Basic-Tox-concepts
[Definition table]: #Definition-table
[Create a profile]: #Create-a-profile

[Customize your profile]: #Customize-your-profile
[Name]: #Name
[Status message]: #Status-message
[Avatar]: #Avatar
[Status]: #Status

[Add a friend]: #Add-a-friend
[using a ToxID]: #Using-a-ToxID
[using a Public Key]: #Using-a-Public-Key

[Manage your friend list]
[Accept/Reject a friend request]
[Delete a friend]
[Block a friend]
[Copy friend's Public Key]
[Add notes about a friend]

[Talk with a friend]
[Basic messages]
[Quotes]
[Markdown]

[Send a file]
[Inline images]
[Others files]

[Customize Ricin: Settings]
[General tab]
[Get your ToxID]
[Change your nospam]
[Choose a default save path]

[Network tab]
[Configure the connection method: UDP or TCP]
[Configure a SOCKS5 proxy]

[Interface tab]
[Themes system]
[Choose a language]
[Configure the Ricin interface]

[TEXT NOTES]: #

[profile name]: #dt-profile-name
