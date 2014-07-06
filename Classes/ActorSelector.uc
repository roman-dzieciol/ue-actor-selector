// ============================================================================
//  ActorSelector:	 
//  UnrealEd plugin, adds advanced features for selecting actors.
// 
//  Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
//  http://wiki.beyondunreal.com/wiki/Switch
// ============================================================================
class ActorSelector extends BrushBuilder 
	config;


// ----------------------------------------------------------------------------
// Structs
// ----------------------------------------------------------------------------


enum ESelectMode
{
	Select,			// Find specified actors then Select only them
	Invert,			// Invert selection
	Memorize,		// Save selection in memory
	Recall,			// Restore selection from memory
	SelectAnd,		// Find then AND with previous selection
	SelectOr,		// Find then OR with previous selection
	SelectXor,		// Find then XOR with previous selection
	SelectMemAnd,	// Find then AND with saved selection
	SelectMemOr,	// Find then OR with saved selection
	SelectMemXor	// Find then NOR with saved selection
};

enum EPropertyType
{
	Text,
	PartialText,
	Number,
	Bits
};


// ----------------------------------------------------------------------------
// Structs
// ----------------------------------------------------------------------------

struct SEditorActor
{
	var string Actor;
	var int MaxId;
};


// ----------------------------------------------------------------------------
// Internal
// ----------------------------------------------------------------------------

var array<SEditorActor> EditorActors;			// 
var Actor TempEditorActor;						// 
var ActorSelectorProxy Proxy;					// unrooted object for storing actor references
var string ProxyName;							//


// ----------------------------------------------------------------------------
// Parameters
// ----------------------------------------------------------------------------

var() ESelectMode Mode;
var() config string PName;
var() config string PValue;
var() config EPropertyType PType;
var() bool bOnlySelectable;
var() config bool bUpdateWindows;
var bool bPopWarnings;
var bool bPopResults;


// ----------------------------------------------------------------------------
// Entry point
// ----------------------------------------------------------------------------

event bool Build()
{
	local Actor A;
	
	// Find actor reference
	if( !FindAnyActor(A) )
		return false;	
		
	SetPropertyText("Proxy",ProxyName);
	if( Proxy == None )
	{
		Proxy = new (None) class'ActorSelectorProxy';
		ProxyName = string(Proxy);
	}
	
	if( Proxy == None )
	{
		return PopError("Failed to create proxy object.");
	}	
		
	Proxy.PType = PType;
	Proxy.PName = PName;
	Proxy.PValue = PValue;
	Proxy.Mode = Mode;
	Proxy.bOnlySelectable = bOnlySelectable;
	Proxy.bUpdateWindows = bUpdateWindows;
	
	if( Proxy.PreBuildSelection(A,self) )
	{
		Log( Proxy.SelectCounter @"Actors selected", class.name );
		if( bUpdateWindows )
		{
			A.ConsoleCommand("LEVEL REDRAW");				// Viewports
			A.ConsoleCommand("ACTOR SELECT INVERT");		// F4 properties
			A.ConsoleCommand("ACTOR SELECT INVERT");		//
		}	
	}
	Proxy = None;
	
	SaveConfig();
	return false;
}


// ----------------------------------------------------------------------------
// Internal
// ----------------------------------------------------------------------------

function bool PopResult( coerce string S )
{
	if( bPopResults )
	{
		Log( "" $ S, class.name );
		BadParameters( "" $ S );
	}
	return true;
}

function bool PopWarning( coerce string S )
{
	if( bPopWarnings )
	{
		Log( "Warning: " $ S, class.name );
		BadParameters( "Warning: " $ S );
	}
	return false;
}

function bool PopError( coerce string S )
{
	Log( "Error: " $ S, class.name );
	BadParameters( "Error: " $ S );
	return false;
}

function bool FindAnyActor( out Actor A )
{
	local SEditorActor E;
	local int i,j;
	
	for( i=0; i!=EditorActors.Length; ++i )
	{
		E = EditorActors[i];
		for( j=0; j!=E.MaxId; ++j )
		{
			SetPropertyText("TempEditorActor",E.Actor$j);
			if( TempEditorActor != None )
			{
				A = TempEditorActor;
				TempEditorActor = None;
				return true;
			}
		}
	}	
	return PopError( "Could not find any actors in the level." );
}


// ----------------------------------------------------------------------------
// DefaultProperties
// ----------------------------------------------------------------------------
DefaultProperties
{
	ToolTip="ActorSelector"
	BitmapFilename="ActorSelector"
	
	Mode=Set
	bOnlySelectable=true
	bUpdateWindows=true
	
	bPopWarnings=true
	bPopResults=true
	
	
	EditorActors(0)=(Actor="MyLevel.LevelInfo",MaxId=8)
	EditorActors(1)=(Actor="MyLevel.Camera",MaxId=64)
	EditorActors(2)=(Actor="MyLevel.Brush",MaxId=128)
}
