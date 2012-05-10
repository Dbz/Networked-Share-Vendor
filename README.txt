This is an open source networked vending system. It has a couple pretty cool features. It is a share-vendor, so it allows for other residents to own a copy of the vendor and sell its products. The percentage of the sales that the owner of the vendor gets can be set in the vendor's configuration notecard. It has multiple email handling, so you can have as many products as the vendor can hold (a lot). Furthermore, those emails are signed with a hashed string which verifies that they are legitimate and not from someone trying to steal products. Lastly, the vendor allows for unlimited profit splits.



SET UP:
    CONFIGURATION NOTECARD:
        *Lines starting with "~" are comments and not executed by the script.
        *The configuration of the products in the notecard uses the following format without spaces:
        
                    Product|Notecard|Texture UUID|Price|Split>Split>etc.>
        
        *An example would look like this:
        ~Object|ObjectNode|93515068-2ef8-e1c6-66fe-7557874cb8e1|100|db677501-355c-470b-a4f9-2a4b905e2c63:50>12b22ced-01b5-4f53-9461-e52d7815d6fe:50
        
        *Object Name BAR Notecard Name BAR Product Texture UUID (Key) BAR Item Price BAR Splits
                *Splits are in the format
                        key:percent>key:percent>etc.
    SERVER:
        *Put in the EmailNode.lsl scripts in a prim and make sure the script endings range from 1 to the amount of nodes you have e.g. "EmailNode.lsl 1" to "EmailNode.lsl X."
        *Put in the Configuration notecard, the products' textures, notecards, and objects.
        *Put in the Server.lsl script and open it. There are three variables that need to be set. The password (The same one in the vendor.), the name of the configuration notecard, and the character which marks a comment in the configuration notecard.
    VENDOR:
        *Put in the EmailNode.lsl scripts in a prim and make sure the script endings range from 1 to the amount of nodes you have e.g. "EmailNode.lsl 1" to "EmailNode.lsl X."
        *Put in the Core.lsl script, and open it. There are four variables that need to be set. The key of the server (It is told to you by the server on reset.), whether or not the vendor is a share vendor , the percentage to give to the owner, and the password for the message signature (It needs to be the same as the one in the Server.lsl script.). It is advised that you take the default vendor shape and then change the textures to your own versions if you please.
                        
    
        
Scripted by Sleepy Xue. Open Source 4/14/12