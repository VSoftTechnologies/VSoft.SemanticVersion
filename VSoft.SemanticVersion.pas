{***************************************************************************}
{                                                                           }
{           VSoft.SemanticVErsion - Semantic Version Parsing                }
{                                                                           }
{           Copyright � 2017 Vincent Parrett and contributors               }
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
  TSemanticVersion = record
  private
    FLabel    : string;
    Elements : array[0..2] of word; //version numbers are typically 16 bit unsigned integers
    constructor CreateEmpty(const dummy : integer);
    function GetIsStable : boolean;
    function GetIsEmpty : boolean;
    class function IsDigit(const value : Char) : boolean;static;
  public
    constructor Create(const major, minor : Word);overload;
    constructor Create(const major, minor : Word; const preReleaseLabel : string );overload;
    constructor Create(const major, minor, release : Word);overload;
    constructor Create(const major, minor, release : Word; const preReleaseLabel : string );overload;

    function Clone : TSemanticVersion;
    function CompareTo(const version : TSemanticVersion) : integer;
    function ToString : string;

    class function Parse(const version : string) : TSemanticVersion;static;
    class function TryParse(const version : string; out value : TSemanticVersion) : boolean;static;
    class function Empty : TSemanticVersion; static;

    class operator Equal(a: TSemanticVersion; b: TSemanticVersion) : boolean;
    class operator NotEqual(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator GreaterThan(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator GreaterThanOrEqual(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator LessThan(a : TSemanticVersion; b : TSemanticVersion) : boolean;
    class operator LessThanOrEqual(a : TSemanticVersion; b : TSemanticVersion) : boolean;

    property Major    : Word read Elements[0];
    property Minor    : Word read Elements[1];
    property Patch  : Word read Elements[2];
    property PreReleaseLabel : string read FLabel write FLabel;
    property IsStable : boolean read GetIsStable;
    property IsEmpty  : boolean read GetIsEmpty;
  end;

implementation

uses
  System.SysUtils;

{ TSemanticVersion }

function TSemanticVersion.Clone: TSemanticVersion;
begin
  result := TSemanticVersion.Create(Major, Minor, Patch, PreReleaseLabel);
end;

function TSemanticVersion.CompareTo(const version: TSemanticVersion): integer;
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    result := Self.Elements[i] - version.Elements[i];
    if result <> 0 then
      exit;
  end;

  //if we get here, version fields are equal.. so compare the labels
  // label > no label?? Is this right?
  if Self.PreReleaseLabel <> version.PreReleaseLabel then
  begin
    if Self.PreReleaseLabel = '' then
      Exit(1)
    else if version.PreReleaseLabel = '' then
      Exit(-1);
    Result := CompareText(Self.PreReleaseLabel, version.PreReleaseLabel);
  end;
end;

constructor TSemanticVersion.Create(const major, minor: Word);
begin
  Create(major,minor,0,'');
end;

constructor TSemanticVersion.Create(const major, minor, release: Word);
begin
  Create(major, minor, release, PreReleaseLabel);
end;

constructor TSemanticVersion.CreateEmpty(const dummy: integer);
begin
  Elements[0] := 0;
  Elements[1] := 0;
  Elements[2] := 0;
  FLabel := '';
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
  result := FLabel = '';
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
begin
  result := TSemanticVersion.Empty;
  sValue := version.Trim();
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
        break;
    end;
    if currentElement <> '' then
    begin
      Result.Elements[e] := StrToInt(currentElement);
      Inc(count);
    end;
    if (i <= len) and (sValue[i] = '.') then
      Inc(i);
  end;
  if sValue[i] = '-' then
  begin
    Inc(i);
    if i <= len then
      result.FLabel := Copy(sValue,i,len);
  end
  else
  begin
    if i <= len then
      raise EArgumentException.Create('Not a valid version string - Too many parts, max of 3 integer parts, e.g: 1.2.3 and optional label, e.g: 1.2.3-Beta1');

  end;


  if count < 2 then
    raise EArgumentException.Create('Not a valid version string - needs at least two parts, e.g: 1.0');


end;

function TSemanticVersion.ToString: string;
begin
  if IsEmpty then
    Exit('');

  if FLabel = '' then
    result := Format('%d.%d.%d',[Major, Minor, Patch])
  else
    result := Format('%d.%d.%d-%s',[Major, Minor, Patch,FLabel]);
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

constructor TSemanticVersion.Create(const major, minor: Word; const preReleaseLabel: string);
begin
  Create(major,minor,0,preReleaseLabel);
end;

constructor TSemanticVersion.Create(const major, minor, release: Word; const preReleaseLabel: string);
begin
  Elements[0] := major;
  Elements[1] := minor;
  Elements[2] := release;
  FLabel      := preReleaseLabel;

end;

end.
