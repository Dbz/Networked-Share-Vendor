# Networked Share Vendor

This is an open source networked vending system. It has a couple pretty cool features.

 - Share vending (Someone can operate your vendor in their shop and recieve commision)
 - Configurable share vending commision percentage 
 - Profit splitting
 - Unlimited products
 - Hashed message signing security which will disallow product theft by verifying all communication between vendors and the server

# System Setup

## Configuration Notecard:

Lines starting with "~" are comments and not executed by the script (This character can be changed in the server script).
The configuration of the products in the notecard uses the following format without spaces:
        
`ProductName|ProductNotecardName|Texture UUID|Price|Split>Split>...>Split`

Splits are in the format:

`key:percent>key:percent`
        
An example would look like this:

`Object|ObjectNote|93515068-2ef8-e1c6-66fe-7557874cb8e1|100|db677501-355c-470b-a4f9-2a4b905e2c63:50>12b22ced-01b5-4f53-9461-e52d7815d6fe:50`


    
## Server:

 1. Put the EmailNode.lsl scripts in a prim and make sure the script endings range from 1 to the amount of nodes you have e.g. "EmailNode.lsl 1" to "EmailNode.lsl X"
 2. Put in the Configuration notecard, the products' textures, notecards, and objects.
 3. Put in the Server.lsl script and open it. There are three variables that need to be set:
    - The password (same for both server and vendor)
    - The name of your configuration notecard
    - The character which marks a comment in the configuration notecard. (In my example, I used `~`)

## Vendor:

 1. Put the EmailNode.lsl scripts in a prim and make sure the script endings range from 1 to the amount of nodes you have e.g. "EmailNode.lsl 1" to "EmailNode.lsl X"
 2. Put in the Core.lsl script, and open it. There are four variables that need to be set:
    - The key of the server (It is told to you by the server on reset.)
    - Whether or not the vendor is a share vendor (If it is a share vendor, then it is not for personal use, and you give it to someone else)
    - The share vendor commision percentage
    - The password for the message signature (It needs to be the same as the one in the Server.lsl script.)

It is advised that you take the default vendor shape and then change the textures to your own versions.
                        
    
        
Scripted by Sleepy Xue (Daniel Burt). Open Source 4/14/12
