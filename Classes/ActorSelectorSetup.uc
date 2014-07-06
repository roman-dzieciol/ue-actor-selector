// ============================================================================
//  ActorSelectorSetup:	 
//  UnrealEd plugin, opens special properties window for selected actor.
// 
//  Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
//  http://wiki.beyondunreal.com/wiki/Switch
// ============================================================================
class ActorSelectorSetup extends Commandlet;

var string AddPackage;
var string RemovePackage;

var string ObjectClass;
var string ArrayName;
var array<string> PackagesArray;


event int Main( string Parms )
{		
	local class C;
	local object O;
	local int i;
	
	// Load class
	C = class(DynamicLoadObject( ObjectClass, class'Class', true ));
	if( C == None )
	{
		Log( "Failed to load class: ["$ ObjectClass $"]", 'Error' );
		return 1;	
	}
	
	// Create object
	O = new C;
	if( O == None )
	{
		Log( "Failed to create object of class: ["$ C $"]", 'Error' );
		return 1;	
	}
	
	// Get EditPackages array
	SetPropertyText("PackagesArray",O.GetPropertyText(ArrayName));
	
	// Modify the array
	if( AddPackage != "" )
	{
		Log( "Adding "$ ObjectClass $"."$ ArrayName $"="$ AddPackage $"..." );
		
		// see if it's already in the array
		for( i=0; i!=PackagesArray.Length; ++i )
		{
			if( AddPackage ~= PackagesArray[i] )
			{
				return 0;
			}
		}
		
		// add
		PackagesArray[i] = AddPackage;
		O.SetPropertyText(ArrayName,GetPropertyText("PackagesArray"));
		O.SaveConfig();
		return 0;
	}
	else if( RemovePackage != "" )
	{
		Log( "Removing "$ ObjectClass $"."$ ArrayName $"="$ RemovePackage $"..." );
		
		// find it in the array
		for( i=0; i!=PackagesArray.Length; ++i )
		{
			if( RemovePackage ~= PackagesArray[i] )
			{
				PackagesArray.remove(i,1);
				O.SetPropertyText(ArrayName,GetPropertyText("PackagesArray"));
				O.SaveConfig();
				return 0;
			}
		}		
		
		// not found
		return 0;
	} 

	Log( "Unknown command: ["$ Parms $"]", 'Error' );
	return 1;	
}


// ----------------------------------------------------------------------------
// DefaultProperties
// ----------------------------------------------------------------------------
DefaultProperties
{
	ShowErrorCount=true
	ShowBanner=false
	ObjectClass="Editor.EditorEngine"
	ArrayName="EditPackages"
}