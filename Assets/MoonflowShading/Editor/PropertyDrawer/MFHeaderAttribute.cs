using UnityEngine;

public class MFHeaderAttribute: PropertyAttribute
{
    public string name;

    public MFHeaderAttribute()
    {
        name = "";
    }

    public MFHeaderAttribute(string n)
    {
        name = n;
    }
}
