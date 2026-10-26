{***************************************************************************}
{                                                                           }
{           VSoft.SemanticVErsion - Semantic Version Parsing                }
{                                                                           }
{           Copyright © 2017 Vincent Parrett and contributors               }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           https://www.finalbuilder.com                                    }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit VSoft.SemanticVersion;

interface


type
  TFileVersion = record
    Major : Word;
    Minor : Word;
    Release : Word;
    Build  : Word;
    function ToString : string;
  end;

  TSemanticVersion = record
  private
    FPreReleaseTag    : string;
    FMetaData : string;
    FElements : array[0..2] of Cardinal; //version numbers are typically 16 bit unsigned integers
    constructor CreateEmpty(const dummy : integer);
    function GetIsStable : boolean;
    function GetIsEmpty : boolean;
    class function IsDigit(const value : Char) : boolean;static;
    class function CompareTags(const a, b : string) : integer;static;
  public
    constructor Create(const major, minor : Cardinal);overload;
    constructor Create(const major, minor : Cardinal; const preReleaseTag : string );overload;
    constructor Create(const major, minor, patch : Cardinal);overload;
    constructor Create(const major, minor, patch : Cardinal; const preReleaseTag : string; const metaData : string );overload;

    function Clone : TSemanticVersion;
    function CompareTo(const version : TSemanticVersion) : integer;
    function ToString : string;
    function ToStringNoMeta : string;


    // Semver doesn't map well to windows fileversion, so this is a hack.
    //
    // so we use ranges -
    //  0-1999 is for anything other than beta or release (eg. alpha)
    //  2000-4999 is for beta
    //  5000 is a release build.
    // for non release builds, if the pre-release tag has any numeric (all digit) segments, the first will be used
    // note that in semver - 0.1.2 > 0.1.2-alpha.1000
    // 0.1.2-alpha.2 = 0.1.2.2
    // 0.1.2-beta.5 = 0.1.2.2005
    // 0.1.2 = 0.1.2.5000.
    // raises EArgumentOutOfRangeException if Major, Minor or Patch is larger than 65535, or if the
    // pre-release number does not fit in its range (larger than 1999, or 2999 for beta).

    function ToFileVersion : TFileVersion;
    function ToFileVersionString : string;

    class function Parse(const version : string) : TSemanticVersion;static;
    class function TryParse(const version : string; out value : TSemanticVersion) : boolean;static;
    class function TryParseWithError(const version : string; out value : TSemanticVersion; out error : string) : boolean;static;
    class function Empty : TSemanticVersion; static;

    class operator Equal(a: TSemanticVersion; b: TSemanticVersion) : boolean;
    class operator NotEqual(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator GreaterThan(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator GreaterThanOrEqual(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator LessThan(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator LessThanOrEqual(a : TSemanticVersion; b : TSemanticVersion) : boolean;

    property Major    : Cardinal read FElements[0] write FElements[0];
    property Minor    : Cardinal read FElements[1] write FElements[1];
    property Patch  : Cardinal read FElements[2] write FElements[2];
    property PreReleaseTag : string read FPreReleaseTag write FPreReleaseTag;
    property IsStable : boolean read GetIsStable;
    property IsEmpty  : boolean read GetIsEmpty;
    property MetaData : string read FMetaData write FMetaData;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils;

{ TSemanticVersion }

function TSemanticVersion.Clone: TSemanticVersion;
begin
  result := TSemanticVersion.Create(Major, Minor, Patch, PreReleaseTag, MetaData);
end;

function Max(const a, b : integer) : integer;
begin
  if a > b then
    result := a
  else
    result := b;
end;

function CompareInt(const a, b : integer) : integer;
begin
  result := 0;
  if a > b  then
    result := 1
  else if a < b then
    result := -1;
end;

//do not subtract - a Cardinal subtraction wraps (or raises with $Q+/$R+) when the values are 2^31 or more apart.
function CompareCardinal(const a, b : Cardinal) : integer;
begin
  result := 0;
  if a > b  then
    result := 1
  else if a < b then
    result := -1;
end;

//borrowed from stringhelper, works in more versions of delphi
function SplitStr(const value : string; const Separator: Char): TArray<string>;
const
  DeltaGrow = 4; //we are not likely to need a lot
var
  NextSeparator, LastIndex: Integer;
  Total: Integer;
  CurrentLength: Integer;
  s : string;
begin
  Total := 0;
  LastIndex := 1;
  CurrentLength := 0;
  NextSeparator := PosEx(Separator,value, LastIndex);
  while (NextSeparator > 0)  do
  begin
    s := Copy(value, LastIndex, NextSeparator - LastIndex);
    if (S <> '') or (S = '') then
    begin
      Inc(Total);
      if CurrentLength < Total then
      begin
        CurrentLength := Total + DeltaGrow;
        SetLength(Result, CurrentLength);
      end;
      Result[Total - 1] := S;
    end;
    LastIndex := NextSeparator + 1;
    NextSeparator :=  PosEx(Separator,value, LastIndex);
  end;

  if (LastIndex <= Length(value)) then
  begin
    Inc(Total);
    SetLength(Result, Total);
    Result[Total - 1] := Copy(value,LastIndex, Length(value) - LastIndex + 1);
  end
  else
    SetLength(Result, Total);
end;

//a numeric identifier is all digits - StrToInt would also accept signs and hex prefixes ($, 0x).
function IsNumericIdentifier(const value : string) : boolean;
var
  i : integer;
begin
  result := value <> '';
  for i := 1 to Length(value) do
  begin
    if not TSemanticVersion.IsDigit(value[i]) then
      exit(false);
  end;
end;

function TrimLeadingZeros(const value : string) : string;
var
  i : integer;
begin
  i := 1;
  //leave at least one digit
  while (i < Length(value)) and (value[i] = '0') do
    Inc(i);
  result := Copy(value, i, Length(value));
end;

//compares numeric identifiers of any length, without converting them to integers which may overflow.
function CompareNumericIdentifiers(const a, b : string) : integer;
var
  sA : string;
  sB : string;
begin
  sA := TrimLeadingZeros(a);
  sB := TrimLeadingZeros(b);
  //without leading zeros, the longer one is the larger number
  result := CompareInt(Length(sA), Length(sB));
  if result = 0 then
    result := CompareStr(sA, sB);
end;


class function TSemanticVersion.CompareTags(const a, b: string): integer;
var
  i      : integer;
  aLen   : integer;
  bLen   : integer;
  maxLen : integer;

  sA     : string;
  sB     : string;
  aIsNumeric : boolean;
  bIsNumeric : boolean;
  aParts : TArray<string>;
  bParts : TArray<string>;
begin
  result := 0;
  aParts := SplitStr(a,'.');
  bParts := SplitStr(b,'.');

  aLen := Length(aParts);
  bLen := Length(bParts);
  //both should have at least 1 element, otherwise we should not have gotten here!
  Assert(aLen >= 1);
  Assert(bLen >= 1);

  maxLen := Max(aLen, bLen);

  for i := 0 to maxLen -1 do
  begin
    sA := '';
    sB := '';
    aIsNumeric := false;
    bIsNumeric := false;
    if i < aLen then
    begin
      sA := aParts[i];
      aIsNumeric := IsNumericIdentifier(sA);
    end;
    if i < bLen then
    begin
      sB := bParts[i];
      bIsNumeric := IsNumericIdentifier(sB);
    end;

    //if the string values are exactly the continue
    if CompareStr(sA, sB) = 0 then
      continue;

    if sA = '' then
      exit(-1);
    if sB = '' then
      exit(1);

    if aIsNumeric and bIsNumeric then
    begin
      result := CompareNumericIdentifiers(sA, sB);
      if result <> 0 then
        exit
      else
        continue;
    end
    else if (not aIsNumeric) and (not bIsNumeric) then
    begin
      result := CompareStr(sA,sB);
      if result <> 0 then
        exit
      else
        continue;
    end
    else if aIsNumeric and (not bIsNumeric) then
    begin
      exit(-1);
    end
    else
      exit(1);
  end;
end;

function TSemanticVersion.CompareTo(const version: TSemanticVersion): integer;
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    result := CompareCardinal(FElements[i], version.FElements[i]);
    if result <> 0 then
      exit;
  end;

  //if we get here, version fields are equal.. so compare the Tags
  // Tag < no Tag
  if CompareStr(Self.PreReleaseTag,version.PreReleaseTag) <> 0 then
  begin
    if Self.PreReleaseTag = '' then
      Exit(1) //self greater than version
    else if version.PreReleaseTag = '' then
      Exit(-1); //self less than version
    Result := TSemanticVersion.CompareTags(self.PreReleaseTag, version.PreReleaseTag);
  end
  else
    result := 0;
end;

constructor TSemanticVersion.Create(const major, minor: Cardinal);
begin
  Create(major,minor,0,'','');
end;

constructor TSemanticVersion.Create(const major, minor, patch: Cardinal);
begin
  Create(major, minor, patch, '','');
end;

constructor TSemanticVersion.CreateEmpty(const dummy: integer);
begin
  FElements[0] := 0;
  FElements[1] := 0;
  FElements[2] := 0;
  FPreReleaseTag := '';
  FMetaData := '';
end;

class function TSemanticVersion.Empty: TSemanticVersion;
begin
  result := TSemanticVersion.CreateEmpty(0);
end;

class operator TSemanticVersion.Equal(a, b: TSemanticVersion): boolean;
begin
  result := a.CompareTo(b) = 0;
end;


function TSemanticVersion.GetIsEmpty: boolean;
begin
  result := (Major = 0) and (Minor = 0) and (Patch = 0);
end;

function TSemanticVersion.GetIsStable: boolean;
begin
  result := FPreReleaseTag = '';
end;

class operator TSemanticVersion.GreaterThan(a, b: TSemanticVersion): boolean;
begin
  result := a.CompareTo(b) > 0;
end;

class operator TSemanticVersion.GreaterThanOrEqual(a, b: TSemanticVersion): boolean;
begin
  result := a.CompareTo(b) >= 0;
end;

class function TSemanticVersion.IsDigit(const value: Char): boolean;
const
  digits  = ['0'..'9'];
begin
  result := CharInSet(value,digits);
end;

class operator TSemanticVersion.LessThan(a, b: TSemanticVersion): boolean;
begin
  result := a.CompareTo(b) < 0;
end;

class operator TSemanticVersion.LessThanOrEqual(a, b: TSemanticVersion): boolean;
begin
  result := a.CompareTo(b) <= 0;
end;

class operator TSemanticVersion.NotEqual(a, b: TSemanticVersion): boolean;
begin
  result := a.CompareTo(b) <> 0;
end;


class function TSemanticVersion.Parse(const version: string): TSemanticVersion;
var
  len : integer;
  i : integer;
  e : integer;
  currentElement : string;
  sValue : string;
  count : integer;
  TagStart : integer;

  procedure ParseMetaData;
  begin
    Inc(i);
    if i > len then
      raise EArgumentException.Create('Not a valid version string - the metadata after ''+'' is empty');
    result.FMetaData := Copy(sValue,i,len);
    i := len + 1;
  end;

  procedure ParseTag;
  begin
    Inc(i);
    TagStart := i;
    while i <= len do
    begin
      if sValue[i] <> '+' then
        Inc(i)
      else
        break;
    end;
    result.FPreReleaseTag := Copy(sValue,TagStart,i - TagStart);
    if result.FPreReleaseTag = '' then
      raise EArgumentException.Create('Not a valid version string - the pre-release tag after ''-'' is empty');
    //the tag may run to the end of the string, in which case i = len + 1
    if (i <= len) and (sValue[i] = '+') then
    begin
      ParseMetaData;
    end;
  end;

  function IsDecimalInteger(const value : string): Boolean;
  var
    i : integer;
  begin
    result := true;
    for i := 1 to Length(value) do
      if not TSemanticVersion.IsDigit(value[i]) then
      begin
        Result := False;
        exit;
      end;
  end;

  //StrToInt would reject values above MaxInt, and StrToUInt is not available in older versions of delphi.
  //value must only contain digits.
  function ElementToCardinal(const value : string) : Cardinal;
  var
    j : integer;
    digit : Cardinal;
  begin
    result := 0;
    for j := 1 to Length(value) do
    begin
      digit := Ord(value[j]) - Ord('0');
      if result > (High(Cardinal) - digit) div 10 then
        raise EArgumentException.Create('Not a valid version string - [' + value + '] is too large, the maximum is ' + IntToStr(High(Cardinal)));
      result := result * 10 + digit;
    end;
  end;


begin
  result := TSemanticVersion.Empty;
  sValue := Trim(version);
  len := Length(sValue);
  currentElement := '';
  i := 1;
  count := 0;

  //iterate the numeric elements
  for e := 0 to 2 do
  begin
    currentElement := '';
    while i <= len do
    begin
      if TSemanticVersion.IsDigit(sValue[i]) then
      begin
        currentElement := currentElement + sValue[i];
        Inc(i);
      end
      else
      begin
        if not CharInSet(sValue[i], ['.', '-', '+']) then
          currentElement := currentElement + sValue[i];
        break;
      end;

    end;
    if currentElement <> '' then
    begin
      if not IsDecimalInteger(currentElement) then
        raise EArgumentException.Create('Not a valid version string - [' + currentElement + '] is not an integer');
      Result.FElements[e] := ElementToCardinal(currentElement);
      Inc(count);
    end;
    //don't skip the . if we are parsing the last valid element
    if (e < 2) and (i <= len) and (sValue[i] = '.') then
      Inc(i);
  end;
  //check the last char too, a trailing separator is not valid
  if i <= len then
  begin
    case sValue[i] of
      '-' : //a Tag follows
      begin
        ParseTag;
      end;
      '+' : //everything that follows is metadata
      begin
        ParseMetaData;
      end;
    else
      raise EArgumentException.Create('Not a valid version string, invalid char at position : [' + IntToStr(i) + '] ''' + sValue[i] + '''');
    end;
  end;

  if count < 2 then
    raise EArgumentException.Create('Not a valid version string - needs at least two parts, e.g: 1.0');


end;

function TSemanticVersion.ToFileVersion: TFileVersion;
var
  build : integer;
  preReleaseBase : integer;
  preReleaseMax : integer;
  elements : TArray<string>;
  element : string;
  number : string;

  //the file version elements are Words, raise rather than truncate.
  procedure CheckElement(const name : string; const value : Cardinal);
  begin
    if value > High(Word) then
      raise EArgumentOutOfRangeException.Create(Format('Cannot convert to a file version - %s [%u] is larger than %u', [name, value, High(Word)]));
  end;

begin
  CheckElement('Major', Major);
  CheckElement('Minor', Minor);
  CheckElement('Patch', Patch);
  build := 5000; //release base
  preReleaseBase := 0;
  preReleaseMax := 1999;
  if not Self.IsStable then //has a prerelease tag
  begin
    if Pos('beta', FPreReleaseTag) > 0 then
    begin
      preReleaseBase := 2000;
      preReleaseMax := 4999;
    end;
    elements := SplitStr(FPreReleaseTag, '.');
    for element in elements do
    begin
      if IsNumericIdentifier(element) then
      begin
        number := TrimLeadingZeros(element);
        //raise rather than overflow into the next range. more than 4 digits never fits, and may be too large for StrToInt.
        if (Length(number) > 4) or (preReleaseBase + StrToInt(number) > preReleaseMax) then
          raise EArgumentOutOfRangeException.Create(Format('Cannot convert to a file version - the number [%s] in the pre-release tag [%s] is larger than %d',
                                                           [element, FPreReleaseTag, preReleaseMax - preReleaseBase]));
        build := preReleaseBase + StrToInt(number);
        break;
      end;
    end;
  end;
  result.Major := Major;
  result.Minor := Minor;
  result.Release := Patch;
  result.Build := build;
end;

function TSemanticVersion.ToFileVersionString: string;
var
  fileVersion : TFileVersion;
begin
  fileVersion := ToFileVersion;
  result := fileVersion.ToString;
end;

function TSemanticVersion.ToString: string;
begin
  if IsEmpty then
    Exit('');

  if FPreReleaseTag = '' then
    result := Format('%u.%u.%u',[Major, Minor, Patch])
  else
    result := Format('%u.%u.%u-%s',[Major, Minor, Patch,FPreReleaseTag]);
  if FMetaData <> '' then
    result := result + '+' + FMetaData;
end;

function TSemanticVersion.ToStringNoMeta: string;
begin
  if IsEmpty then
    Exit('');

  if FPreReleaseTag = '' then
    result := Format('%u.%u.%u',[Major, Minor, Patch])
  else
    result := Format('%u.%u.%u-%s',[Major, Minor, Patch,FPreReleaseTag]);
end;

class function TSemanticVersion.TryParseWithError(const version: string; out value: TSemanticVersion; out error: string): boolean;
begin
  result := true;
  try
    value := Parse(version);
  except
    on e : Exception do
    begin
      result := False;
      error := e.Message;
    end;
  end;
end;

class function TSemanticVersion.TryParse(const version: string; out value: TSemanticVersion): boolean;
begin
  result := true;
  try
    value := Parse(version);
  except
    result := False;
  end;
end;

constructor TSemanticVersion.Create(const major, minor: Cardinal; const preReleaseTag: string);
begin
  Create(major,minor,0,preReleaseTag,'');
end;

constructor TSemanticVersion.Create(const major, minor, patch: Cardinal; const preReleaseTag, metaData: string);
begin
  FElements[0] := major;
  FElements[1] := minor;
  FElements[2] := patch;
  FPreReleaseTag      := preReleaseTag;
  FMetaData   := metaData;
end;


{ TFileVersion }

function TFileVersion.ToString: string;
begin
  result := Format('%d.%d.%d.%d', [Major, Minor, Release, Build]);
end;

end.
