// ============================================================================
//  ActorSelectorProxy:	 Unrooted object for storing actor references.
//  UnrealEd plugin, adds advanced features for selecting actors.
// 
//  Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
//  http://wiki.beyondunreal.com/wiki/Switch
// ============================================================================
class ActorSelectorProxy extends Object;


/*	NOTE
	- Actor references are used as workaround for the swap-names-on-duplication
	  engine feature. UED may or may not crash if referenced actor is deleted 
	  before ActorSelectorProxy. No crashes observed so far.
*/


// ----------------------------------------------------------------------------
// Internal
// ----------------------------------------------------------------------------

var int 	CIntegerA,	CIntegerB;				//
var float	CFloatA,	CFloatB;				//
var transient array<Object> Memorized;			//
var bool bInputIsFloat;							//


// ----------------------------------------------------------------------------
// Parameters
// ----------------------------------------------------------------------------

var() ActorSelector.EPropertyType PType;
var() string PName;
var() string PValue;
var() ActorSelector.ESelectMode Mode;
var() bool bOnlySelectable;
var() bool bUpdateWindows;
var() int SelectCounter;

final function bool ShouldBeSelected( Actor O, string A, string B )
{		
	switch( PType )
	{
		case Text:
			//Log( "Text"@ O @ A @ B );
			return ( A ~= B );
			break;
			
		case PartialText:
			//Log( "PartialText"@ O @ A @ B );
			return Instr(B,A) != -1;
			break;
		
		case Number:
			if( bInputIsFloat || Instr(B,".") != -1 )
			{
				SetPropertyText("CFloatA",A);
				SetPropertyText("CFloatB",B);
				//Log( "Float"@ O @ CFloatA @ CFloatB );
				return ( CFloatA == CFloatB );
			}
			else if( Instr(B,".") != -1 )
			{
				SetPropertyText("CIntegerA",A);
				SetPropertyText("CIntegerB",B);
				//Log( "Integer"@ O @ CIntegerA @ CIntegerB );
				return ( CIntegerA == CIntegerB );
			}
			break;
							
		case Bits:
			SetPropertyText("CIntegerA",A);
			SetPropertyText("CIntegerB",B);
			//Log( "Bits"@ O @ CIntegerA @ CIntegerB  );
			return ( (CIntegerB & CIntegerA) == CIntegerA );
			break;
	}
	return false;
}



final function bool PreBuildSelection( Actor Ref, ActorSelector B )
{
	local ActorSelector.ESelectMode oldmode;
	local bool bModeSelect, bModeMem;
	
	SelectCounter = 0;
	
	bModeSelect = 
	(	Mode == Select
	||	Mode == SelectAnd
	||	Mode == SelectOr
	||	Mode == SelectXor
	||	Mode == SelectMemAnd
	||	Mode == SelectMemOr
	||	Mode == SelectMemXor );
	
	bModeMem = 
	(	Mode == Memorize
	||	Mode == Recall
	||	Mode == SelectMemAnd
	||	Mode == SelectMemOr
	||	Mode == SelectMemXor );
	
	switch( PType )
	{
		case Bits:
		case Number:
		
			while( Left(PValue,1) == " " )
				PValue = Mid(PValue,1);
				
			while( Right(PValue,1) == " " )
				PValue = Left(PValue,Len(PValue)-1);
				
			bInputIsFloat = Instr(PValue,".") != -1;
			break;
	}
	
	if( bModeSelect )
	{
		if( PName == "" )
			return B.PopError("Mode"@ GetEnum(enum'ActorSelector.ESelectMode',Mode) @"requires Property Name");
			
		if( PValue == "" )
			return B.PopError("Mode"@ GetEnum(enum'ActorSelector.ESelectMode',Mode) @"requires Property Value");
	}	
	
	if( bModeMem && Mode != Memorize )
	{
		if( Memorized.Length == 0 )
			return B.PopError("Mode"@ GetEnum(enum'ActorSelector.ESelectMode',Mode) @"failed: no memorized actors.");
	}	
	
	switch( Mode )
	{
		case Memorize:
			Memorized.remove(0,Memorized.Length);
			break;			

		case SelectMemAnd:	
		case SelectMemOr:	
		case SelectMemXor:	
			oldmode = Mode;
			Mode = Recall;
			PreBuildSelection(Ref,B);
			Mode = oldmode;
			SelectCounter = 0;
			break;	
	}		

	return BuildSelection(Ref,B);
}


final function bool BuildSelection( Actor Ref, ActorSelector B )
{	
	local Actor A;
	
	foreach Ref.AllActors(class'Actor', A)
	{
		if( bOnlySelectable && !IsTransactional(A) )
		{
			//Log( "Skipping non-transactional actor"@ A );
			A.bSelected = false;
			continue;
		}
		
		if( bOnlySelectable && A.bHiddenEd )
		{
			//Log( "Skipping bHiddenEd actor"@ A );
			A.bSelected = false;
			continue;
		}
	
		switch( Mode )
		{
			case Select:
				A.bSelected = ShouldBeSelected( A, PValue, A.GetPropertyText(PName) );
				if( A.bSelected )
					++SelectCounter;
				break;	

			case Invert:
				A.bSelected = !A.bSelected;
				if( A.bSelected )
					++SelectCounter;
				break;	

			case Memorize:
				if( A.bSelected )
				{
					Memorized[Memorized.Length] = A;
					++SelectCounter;
				}
				break;		

			case Recall:
				A.bSelected = false;
				break;	

			case SelectMemAnd:
			case SelectAnd:
				A.bSelected = A.bSelected && ShouldBeSelected( A, PValue, A.GetPropertyText(PName) );
				if( A.bSelected )
					++SelectCounter;
				break;	

			case SelectMemOr:
			case SelectOr:
				A.bSelected = A.bSelected || ShouldBeSelected( A, PValue, A.GetPropertyText(PName) );
				if( A.bSelected )
					++SelectCounter;
				break;	

			case SelectMemXor:
			case SelectXor:
				A.bSelected = A.bSelected ^^ ShouldBeSelected( A, PValue, A.GetPropertyText(PName) );
				if( A.bSelected )
					++SelectCounter;
				break;	
		}		
	}		
	
	return PostBuildSelection(Ref,B);
}

final function bool PostBuildSelection( Actor Ref, ActorSelector B )
{
	local int i;
	local Actor A;
	
	switch( PType )
	{
		default:
			break;
	}
	
	switch( Mode )
	{
		case Recall:
			for( i=0; i!=Memorized.Length; ++i )
			{
				A = Actor(Memorized[i]);
				if( A != None )
				{
					A.bSelected = true;
					++SelectCounter;
				}
			}
			break;	
	}		
	
	return true;
}


function bool IsTransactional( Actor O )
{
	return ((O.ObjectFlags & 0x00000001) == 0x00000001);
}


// ----------------------------------------------------------------------------
// DefaultProperties
// ----------------------------------------------------------------------------
DefaultProperties
{

}
