/*
    Open Sourced and Scripted
    by Sleepy Xue
    v1.4b Vendor
*/

// User variables
string SERVER           = "2a780c8d-4857-8109-d82e-194b4d2090fa";   // Server Key
integer SHAREVENDOR     = TRUE;                                     // Sharvendors give the owner a percentage
float SHAREVENDOR_FEE   = 20.0;                                     // Give the percentage defined to the owner (20% in example)
string PASSWORD         = "RawrIAmALion??";                         // Password for signature

// Application variables
integer gOnline;                                                    // Controls the usability of the vendor (touch event)
integer gIndex;                                                     // The index for what image/price/texture is showing
list gImages            = [];
list gPrices            = [];
list gSplits            = [];
integer gListLength;                                                // The length of the lists is kept for tests in move()
key gQueryID;                                                       // The request ID for tracking in the http_request event
string gURL;                                                        // The Vendor's URL for HTTP requests
string gServerURL;                                                  // The Server's URL for HTTP requests
string gMessage;                                                    // If a request fails, save the message, request a new url, and resend

// Constants
list VENDOR_PRIM        = [PRIM_SIZE, <2.203850, 1.763080, 0.055096>,
                            PRIM_TYPE, 0, 0, <0.0, 1.0, 0.0>, 0.0,
                            <0.0, 0.0, 0.0>, <0.75, 0.9, 0.0>,
                            <0.0, -0.050, 0.0>,
                            PRIM_TEXTURE,
                                        0, "d16a6857-783a-9534-2d70-ef9dafa3d88f", <-1.0, -1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,
                            PRIM_TEXGEN, 2, PRIM_TEXGEN_PLANAR,
                            PRIM_TEXTURE,
                                        2, "4acf1453-b88e-2367-6746-216273b45cec", <6.380851, 0.425390, 0.0>, <0.500198, 0.0, 0.0>, 4.712389,
                            PRIM_TEXGEN, 3, PRIM_TEXGEN_PLANAR,
                            PRIM_TEXTURE,
                                        3, "ebed9112-3f23-b745-41a0-262092925070", <0.340312, 4.253901, 0.0>, <0.0, -0.300027, 0.0>, 0.0,
                            PRIM_TEXGEN, 4, PRIM_TEXGEN_PLANAR,
                            PRIM_TEXTURE,
                                        4, "4acf1453-b88e-2367-6746-216273b45cec", <-6.380851, 0.425390, 0.0>, <0.500198, 0.0, 0.0>, 1.570796

                            ];
                            
// Uses the slave script "EmailNode.lsl"
sendEmail(string message) {
    // str = message signature ? message ? Vendor URL
    llMessageLinked(LINK_THIS, 0,llSHA1String(PASSWORD + message) + "+" + message + "+" + gURL, SERVER);
}

sendRequest(string message) {
    gMessage = message;
    llHTTPRequest(gServerURL, [HTTP_METHOD, "POST"], llSHA1String(PASSWORD + message) + "?" + message);
    // If the server doesn't resond in ten seconds, get a new server URL
    llSetTimerEvent(10.0);
}

// Function to switches the vendor to the next product
move(integer num) {
    // Num is 1 or -1
    // gIndex is the index for all of the lists
    // Add num to the index

    gIndex = gIndex + num;
    
    // If the index is the amountOfProducts +1, then set it to 0
    if(gIndex > gListLength)
        gIndex = 0;
    
    // If index is equal to -1, then set it to the last product
    else if(gIndex < 0)
        gIndex = gListLength;

    llSetTexture(llList2String(gImages,gIndex),0);

    llSetPayPrice(PAY_HIDE,[llList2Integer(gPrices,gIndex)]);
}

// Appropriates money
split(integer amount) {
    
    if(amount < 5) // If the amount is less than 5L, the owner of the vendor can keep it
        return;
        
    // Give the owner their cut
    if(SHAREVENDOR) {
        llGiveMoney(llGetOwner(), llRound((SHAREVENDOR_FEE/100.0)*amount));
        amount -= llRound((SHAREVENDOR_FEE/100.0)*amount);
    }
    
    // Syntax for split (also defined in server config notecard) is:
    // Key:percent>Key:percent>ect.
    // Sperated it into a strided list conaintaining the elements of "Key","Percent"
    list split = llParseString2List(llList2String(gSplits, gIndex),[":",">"],[]);
        
    integer length = llGetListLength(split) /2;
    integer x;
    float percent;
        
    for(x=0;x<length;x++) //Give the correct person their share of the $$$
        llGiveMoney(llList2String(split,x*2), llFloor(amount*(llList2Float(split,x*2+1) / 100.0)));
}

integer isLastRequest() {
    // Works by checking for placeholder spots
    integer len = llGetListLength(gImages);
    integer x;
    for(x=0; x < len; x++)
        if(llStringLength(llList2String(gImages, x)) < 36)
            return 0;
    llSetTimerEvent(0.0);
    return 1;
}

clearLists() {
    gPrices = [];
    gImages = [];
    gSplits = [];
    gIndex = 0;
}

default
{
    on_rez(integer s)
    {
        llResetScript();
    }
    
    state_entry()
    {
        llListen(-34567, "", llGetOwner(), "");
        llDialog(llGetOwner(), "Would you like to turn this prim into the classic vendor shape?", ["Yes", "No"], -34567);
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if(message == "Yes") // Change to my classic vendor shape
            llSetLinkPrimitiveParamsFast(LINK_THIS, VENDOR_PRIM);
        llRequestPermissions(llGetOwner(),PERMISSION_DEBIT);
    }
    
    touch_start(integer num)
    {
        if(llDetectedKey(0) == llGetOwner())
            llDialog(llGetOwner(), "Would you like to turn this prim into the classic vendor shape?", ["Yes", "No"], -34567);
    }
    
    run_time_permissions(integer p)
    {
        if(p & PERMISSION_DEBIT)
            state vend;
        else
            llOwnerSay("Touch the vendor to give permissions");
    }
}

state vend
{
    on_rez(integer s)
    {
        llResetScript();
    }
    
    changed(integer c)
    {
        // URLs won't survive a region restart
        if(c & CHANGED_REGION_START)
            gQueryID = llRequestURL();
    }
    
    state_entry()
    {
        gQueryID = llRequestURL();
    }
    
    timer()
    {
        // If the server doesn't resond in ten seconds, get a new server URL
        sendEmail("request_server_url");
    }

    http_request(key id, string method, string body) 
    {
        // First check is for llRequestURL()
        if(id == gQueryID && method == URL_REQUEST_GRANTED) {
            gQueryID = "";
            gURL = body;
            //llOwnerSay("My url is: " + gURL);
            sendEmail("request_server_url");
            return;
        }
        
        // Server responded, remove the timer
        llSetTimerEvent(0.0);
        
        // Transport lists in comma seperated values(CSVs) from the server to the vendor
        // body = request_number?signature?prices/textures/splits
        
        // Check the message sign for validity
        list temp = llParseString2List(body, ["?"], []);
        if(llSHA1String(PASSWORD + llList2String(temp, 1)) != llList2String(temp, 0))
            return;
        
        // request_number is two 16bit integers OR'd as a 32bit integer.
        // The former is the number of requests, and the latter is the current request number
        integer request_number = llList2Integer(temp, 2);
        temp = llParseString2List(llList2String(temp,1),["+"],[]);
        
        // grabs the server URL
        if(llList2String(temp, 0) == "new_url") {
            gServerURL = llList2String(temp, 1);
                if(llGetListLength(gImages) < 1) {
                    // Get new products if the vendor is empty
                    llOwnerSay("Setting up....");
                    sendRequest("set_up" + "+" + gURL);
                }
                // If the new url was requested because the last one failed, then resend the last message
                else if(gMessage != "")
                    sendRequest(gMessage);
            return;
        }
        
        else if(llList2String(temp, 0) == "transaction_sucess") {
            gMessage = "";
            return;
        }
        
        // From here on, the event is dedicated to sorting the product information
        
        // Note: the requests may not arrive in order:
        // First find out if this is the first of the incoming requests, and if it is,
        // put placeholder spots in all of the lists where the incoming information goes.
        // Then, as the requests arrive, replace the placeholder elements with the real data.
        
        integer requests = request_number & 0xffff;
        
        if(llGetListLength(gImages) < 1) {
            integer x;
            for(x =0; x < (request_number >> 16); x++) {
                gPrices += [x];
                gImages += [x];
                gSplits += [x];
            }
        }
        
        integer index = llListFindList(gImages,[requests]);
        gPrices = llListReplaceList(gPrices, llCSV2List(llList2String(temp,0)), index, index);
        gImages = llListReplaceList(gImages, llCSV2List(llList2String(temp,1)), index, index);
        gSplits = llListReplaceList(gSplits, llCSV2List(llList2String(temp,2)), index, index);
        
        if(isLastRequest()) {
    
            // gListLength is used to bound gIndex in move().
            gListLength = llGetListLength(gImages)-1;

            // Once the move function is called, the vendor starts functioning
            // '0' is entered because 'gIndex + 0' doesn't change gIndex
            move(0);
            gOnline = 1;
            gMessage = "";
            llOwnerSay("/me is now functional");
        }
    }

    touch_start(integer total_number)
    {
        // 0=Display, 3=Help, 2=Left, 4=Right, 5=Backside
        integer face = llDetectedTouchFace(0);
        
        if(llDetectedKey(0) == llGetOwner()) {
            if(face == 5) {
                gOnline = 0;
                clearLists();
                llOwnerSay("Setting up....");
                sendRequest("set_up" + "+" + gURL);
            }
        }
        if(gOnline) {
            // Test for button clicked, then cycle the texture
            if(face == 2)
                move(-1);
            else if(face == 4)
                move(1);

            // Ask the server for the notecard.
            else if(face == 3)
                sendRequest("notecard" + "+" + (string)gIndex + "+" +(string)llDetectedKey(0) + "+" + gURL);
        }
    }
    
    money(key id, integer amount)
    {
        // Check to see the correct amount was paid
        if(amount != llList2Integer(gPrices,gIndex)) {
            llGiveMoney(id, amount);
            return;
        }
        
        sendRequest("inventory" + "+" + (string)gIndex + "+" + (string)id + "+" + gURL);
        
        // It's always nice to tell the customer that his or her purchase is on the way!
        llDialog(id,"Thank you for your business! Your item will be delivered shortly. This can take up to ten minutes. If you never get your item please IM the owner of this vendor with the transaction number. (The transaction number can be found on the Second Life website.)", [],-1);
        
        split(amount);
    }
}