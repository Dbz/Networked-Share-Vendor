/*
    Open Sourced and Scripted
    by Sleepy Xue
    v1.4b Server
*/

// User variables
string PASSWORD     = "RawrIAmALion??"; // Password
string NOTECARD     = "Config";         // The name of the configuration notecard
string COMMENT      = "~";              // Lines in the notecard starting with COMMENT will be discarded

// Application variables
string gURL;                            // The server's URL
integer gLine;                          // Keep track of the current notecard line
integer gTotal;                         // Total lines in the notecard
key gQueryID;                           // Request key for notecard info and server's URL
list gTemp          = [];               // Temp list to save memory
list gInventory     = [];
list gNotecards     = [];
list gTextures      = [];
list gPrices        = [];
list gSplits        = [];

// Constants

key SERVER_KEY;

getNumberOfLines() {
    
    // gTotal will turn into the number of lines 
    gTotal = 0;
    
    // Reset the line counter for llGetNotecardLine() (gLine) because this function is
    // called in the changed event, and the line counter will already at the max
    gLine = 0;
    
    // Clear all data storing lists
    gInventory = [];
    gNotecards = [];
    gTextures = [];
    gPrices = [];
    gSplits = [];
    gTemp = [];
    
    gQueryID = llGetNumberOfNotecardLines(NOTECARD);
}
sendSetUp(string url) {
    // Message = CSV of Prices + seperator + CSV of Images + seperator + CSV of Splits + seperator + number
    string message = llList2CSV(gPrices) + "+" + llList2CSV(gTextures) + "+" + llList2CSV(gSplits);
    
    // Amount of requests to send
    integer requests = llCeil((float)llStringLength(message)/1900.0);
    integer x;
    string m;
    for(x=0; x < requests;x++) {
        
        // Message (m) is 1/requests elements of each list
        m = 
        llList2CSV(llList2List(gPrices, x*llRound((float)llGetListLength(gPrices)/(float)requests), (x+1)*llRound((float)llGetListLength(gPrices)/(float)requests)-1)) + "+" +
        llList2CSV(llList2List(gTextures, x*llRound((float)llGetListLength(gTextures)/(float)requests), (x+1)*llRound((float)llGetListLength(gTextures)/(float)requests)-1)) + "+" +
        llList2CSV(llList2List(gSplits, x*llRound((float)llGetListLength(gSplits)/(float)requests), (x+1)*llRound((float)llGetListLength(gSplits)/(float)requests)-1))
        ;
        
        // The number sent in the request is two 16bit integers OR'd as a 32bit integer.
        // The first number is the number of requests, and the second is the current request number
        // This is followed by the password and then the message
        llHTTPRequest(url, [HTTP_METHOD, "POST"], "?" + llSHA1String(PASSWORD + m) + "?" + m + "?" + (string)((requests << 16) | x));
    }
}

setUp() {
        
    SERVER_KEY = llGetKey();
    
    // Find the amount of notecard lines
    getNumberOfLines();
}


readNotecard() {
    gQueryID = llGetNotecardLine(NOTECARD, ++gLine);
}

default
{
    on_rez(integer s)
    {
        llOwnerSay("Rezzed, but not resetting. Key is: " + (string)llGetKey());
    }
    
    changed(integer c)
    {
        if(c & CHANGED_INVENTORY)
            getNumberOfLines();
        // URLs won't survive a region restart
        else if(c & CHANGED_REGION_START)
            gQueryID = llRequestURL();
    }
    
    state_entry()
    {
        setUp();
    }
    
    dataserver(key query, string data)
    {
        if(query == gQueryID) {
            if(data != EOF) {
                // Find the amount of notecard lines
                if(!gTotal) {
                    // Set gTotal to the number of notecard lines
                    gTotal = (integer)data;
                    readNotecard();
                }
                
                // Discard blank lines and comment lines
                else if(data == "");
                else if(llGetSubString(data,0,0) == COMMENT);
                
                else {
                    // Format is explained in the config notecard
                    gTemp = llParseString2List(data, ["|"], []);
                    gInventory     += [llList2String(gTemp,0)];
                    gNotecards     += [llList2String(gTemp,1)];
                    gTextures      += [llList2String(gTemp,2)];
                    gPrices        += [llList2String(gTemp,3)];
                    gSplits        += [llList2String(gTemp,4)];
                }
                    
                // Lines read so far
                llSetText((string)gLine + "/" + (string)gTotal,<0.0,0.0,0.0>,1.0);
                
                readNotecard();
            }
            
            // Else END OF FILE:
            else
                // Final set up in http_request event
                gQueryID = llRequestURL();
        }
    }

    timer()
    {
        llGetNextEmail("","");
    }
    
    email(string time, string address, string subj, string message, integer num)
    {
        
        // Line below removes the headers of the message
        message = llList2String(llParseString2List(message,["\n\n"],[]),1);
    
        // Check the message sign for validity
        gTemp = llParseString2List(message, ["+"], []);
        if(llSHA1String(PASSWORD + llList2String(gTemp, 1)) != llList2String(gTemp, 0))
            return;
    
        if(llList2String(gTemp, 1) == "request_server_url")
            llHTTPRequest(llList2String(gTemp, 2), [HTTP_METHOD, "POST"], llSHA1String(PASSWORD + "new_url" + "+" + gURL) + "?" + "new_url" + "+" + gURL);

        llGetNextEmail("", "");
    }
    
    http_request(key id, string method, string body)
    {
        // First check is for llRequestURL()
        if(gQueryID == id && method == URL_REQUEST_GRANTED) {
            gQueryID = "";
            gURL = body;
            llSetText("",<0.0,0.0,0.0>,1.0);
            llSetTimerEvent(2.0);
            // Say the key for the user to paste into the vendor
            llOwnerSay("/me key: " + (string)llGetKey());
            return;
        }
        
        // Check the message sign for validity
        gTemp = llParseString2List(body, ["?"], []);
        if(llSHA1String(PASSWORD + llList2String(gTemp, 1)) != llList2String(gTemp, 0))
            return;
        
        gTemp = llParseString2List(llList2String(gTemp, 1), ["+"], []);
        body = llList2String(gTemp,0);
        
        if(body == "set_up")
            sendSetUp(llList2String(gTemp, 1));
        else if(body == "notecard") {
            llGiveInventory(llList2Key(gTemp, 2),llList2String(gNotecards,llList2Integer(gTemp,1)));
            llHTTPRequest(llList2String(gTemp, 3), [HTTP_METHOD, "POST"], "transaction_sucess");
        }
        else if(body == "inventory") {
            llGiveInventory(llList2Key(gTemp, 2),llList2String(gInventory,llList2Integer(gTemp,1)));
            llHTTPRequest(llList2String(gTemp, 3), [HTTP_METHOD, "POST"], "transaction_sucess");
        }
    }
}
