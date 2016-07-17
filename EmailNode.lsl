/*
    Open Sourced and Scripted
    by Sleepy Xue
    v1.4b Node
*/

default
{
    link_message(integer sender, integer num, string str, key id)
    {
        llEmail((string)id+"@lsl.secondlife.com","",str);
        llResetScript();
    }
}