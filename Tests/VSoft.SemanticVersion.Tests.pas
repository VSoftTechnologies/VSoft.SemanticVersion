unit VSoft.SemanticVersion.Tests;

interface
uses
  DUnitX.TestFramework;


type
  {$M+}
  [TestFixture]
  TSemanticVersionTest = class(TObject)
  published
    procedure Will_Fail_with_invalid_versions;

    procedure Can_Create_Version_with_two_components;

    procedure Can_Create_Version_with_three_components;

    procedure Can_Create_Version_with_label;

    procedure Can_Create_Version_with_label_and_metadata;

    // the elements are Cardinals, values above MaxInt must not be formatted as negative numbers.
    procedure ToString_with_large_elements;


    procedure Can_Parse_String_with_two_components;

    procedure Can_Parse_String_with_three_components;

    procedure Can_Parse_String_with_label;

    procedure Can_Parse_String_with_label_and_metadata;

    procedure Can_Parse_String_with_metadata;

    // the pre-release tag runs to the end of the string, Parse must not read past the end (fails with $R+).
    [TestCase('ThreeParts', '1.2.3-beta.1,1,2,3,beta.1')]
    [TestCase('TwoParts',   '1.2-rc.1,1,2,0,rc.1')]
    procedure Can_Parse_String_with_label_at_end(const version : string; const major, minor, patch : Cardinal; const preReleaseTag : string);

    // the elements are Cardinals, so values above MaxInt are valid.
    [TestCase('AboveMaxInt',  '1.0.2147483648,1,0,2147483648')]
    [TestCase('PatchMax',     '1.0.4294967295,1,0,4294967295')]
    [TestCase('AllMax',       '4294967295.4294967295.4294967295,4294967295,4294967295,4294967295')]
    [TestCase('LeadingZeros', '1.0.004294967295,1,0,4294967295')]
    procedure Can_Parse_String_with_large_elements(const version : string; const major, minor, patch : Cardinal);

    [TestCase('PatchMaxPlusOne', '1.0.4294967296')]
    [TestCase('MajorMaxPlusOne', '4294967296.0.0')]
    [TestCase('BeyondInt64',     '1.0.99999999999999999999')]
    procedure Can_Not_Parse_String_with_element_too_large(const version : string);

    // a separator with nothing after it must not be dropped silently.
    [TestCase('TrailingDash',         '1.2.3-')]
    [TestCase('TrailingPlus',         '1.2.3+')]
    [TestCase('TwoPartsTrailingDash', '1.2-')]
    [TestCase('TwoPartsTrailingPlus', '1.2+')]
    [TestCase('LabelTrailingPlus',    '1.2.3-beta+')]
    [TestCase('EmptyLabelWithMeta',   '1.2.3-+meta')]
    [TestCase('TrailingDot',          '1.2.3.')]
    procedure Can_Not_Parse_String_with_dangling_separator(const version : string);

    procedure Can_Not_Parse_String_with_one_component;

    procedure Can_Not_Parse_String_with_invalid_component;

    procedure Can_Not_Parse_String_with_invalid_major;


    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case2','1.2.3+meta,1.2.3')]
    [TestCase('Case3','1.2.3-beta,1.2.3-beta')]
    [TestCase('Case4','1.2.3-beta+meta,1.2.3-beta')]
    [TestCase('Case5','1.2.3-beta+meta,1.2.3-beta+meta')]
    [TestCase('Case6','1.2.3-rc.01,1.2.3-rc.1')]
    procedure Are_Equal(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.0')]
    [TestCase('Case2','1.2.3,1.2.3-beta')]
    procedure Are_Not_Equal(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.2')]
    [TestCase('Case2','1.2.3,1.1.3')]
    [TestCase('Case3','1.2.3,0.2.3')]
    [TestCase('Case4','1.2.3-alpha2,1.2.3-alpha1')]
    [TestCase('Case5','1.2.3-beta1,1.2.3-alpha1')]
    procedure GreaterThan(const a : string; const b : string);


    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case2','1.2.3,1.2.2')]
    [TestCase('Case3','1.2.3,1.1.3')]
    [TestCase('Case4','1.2.3,0.2.3')]
    procedure GreaterThanEqualTo(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case2','1.2.3,1.2.4')]
    procedure NotGreaterThan(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.4')]
    procedure NotGreaterThanEqualTo(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.4')]
    [TestCase('Case2','1.2.3,1.3.3')]
    [TestCase('Case3','1.2.3,2.2.3')]
    procedure LessThan(const a : string; const b : string);


    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case2','1.2.3,1.2.4')]
    [TestCase('Case3','1.2.3,1.3.3')]
    [TestCase('Case4','1.2.3,2.2.3')]
    procedure LessThanEqualTo(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case2','1.2.3,1.2.2')]
    procedure NotLessThan(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.2')]
    procedure NotLessThanEqualTo(const a : string; const b : string);


    [TestCase('Case1','0.0.0,0.0.0-foo')]
    [TestCase('Case2','0.0.1,0.0.0')]
    [TestCase('Case3','1.0.0,0.9.9')]
    [TestCase('Case4','0.10.0,0.9.0')]
    [TestCase('Case5','0.99.0,0.10.0')]
    [TestCase('Case6','2.0.0,1.2.3')]
    [TestCase('Case7','0.0.0,0.0.0-foo')]
    [TestCase('Case8','0.0.1,0.0.0')]
    [TestCase('Case9','1.0.0,0.9.9')]
    [TestCase('Case10','0.10.0,0.9.0')]
    [TestCase('Case11','0.99.0,0.10.0')]
    [TestCase('Case12','2.0.0,1.2.3')]
    [TestCase('Case13','0.0.0,0.0.0-foo')]
    [TestCase('Case14','0.0.1,0.0.0')]
    [TestCase('Case15','1.0.0,0.9.9')]
    [TestCase('Case16','0.10.0,0.9.0')]
    [TestCase('Case17','0.99.0,0.10.0')]
    [TestCase('Case18','2.0.0,1.2.3')]
    [TestCase('Case19','1.2.3,1.2.3-asdf')]
    [TestCase('Case20','1.2.3,1.2.3-4')]
    [TestCase('Case21','1.2.3,1.2.3-4-foo')]
    [TestCase('Case22','1.2.3-5-foo,1.2.3-5')]
    [TestCase('Case23','1.2.3-5,1.2.3-4')]
    [TestCase('Case24','1.2.3-5-foo,1.2.3-5-Foo')]
    [TestCase('Case25','3.0.0,2.7.2+asdf')]
    [TestCase('Case26','1.2.3-a.10,1.2.3-a.5')]
    [TestCase('Case27','1.2.3-a.b,1.2.3-a.5')]
    [TestCase('Case28','1.2.3-a.b,1.2.3-a')]
    [TestCase('Case29','1.2.3-a.b.c.10.d.5,1.2.3-a.b.c.5.d.100')]
    [TestCase('Case30','1.2.3-r2,1.2.3-r100')]
    [TestCase('Case31','1.2.3-r100,1.2.3-R2')]
    [TestCase('Case31','1.2.3,1.2.3-r100')]
    // numeric identifiers of any size compare as numbers, and lower than alphanumeric identifiers
    [TestCase('Case32','1.2.3-rc.10000000000,1.2.3-rc.9999999999')]
    [TestCase('Case33','1.2.3-rc.2147483648,1.2.3-rc.2147483647')]
    [TestCase('Case34','1.2.3-rc.-x,1.2.3-rc.10000000000')]
    // leading zeros do not change the value of a numeric identifier
    [TestCase('Case35','1.2.3-rc.10,1.2.3-rc.009')]
    // only all digit identifiers are numeric, so these compare as text (no hex prefixes)
    [TestCase('Case36','1.2.3-rc.$9,1.2.3-rc.$10')]
    [TestCase('Case37','1.2.3-rc.0x9,1.2.3-rc.0x10')]
    procedure Comparisons(const a : string; const b : string);

    // a > b in every case, with elements 2^31 or more apart so a - b does not fit in an Integer.
    [TestCase('Major',         '4294967295,0,0,5,0,0')]
    [TestCase('Minor',         '1,4294967295,0,1,5,0')]
    [TestCase('Patch',         '1,0,4294967295,1,0,5')]
    [TestCase('PatchVsZero',   '1,0,4294967295,1,0,0')]
    [TestCase('Exactly2Pow31', '1,0,2147483648,1,0,0')]
    procedure Comparisons_with_large_elements(const aMajor, aMinor, aPatch, bMajor, bMinor, bPatch : Cardinal);

    // ToFileVersion - see the comment above TSemanticVersion.ToFileVersion
    //  0-1999    : anything other than beta or release (eg. alpha)
    //  2000-4999 : beta
    //  5000      : release
    // the first numeric (dot separated) segment of the pre-release tag is added to the base.
    [TestCase('Release',          '1.2.3,1,2,3,5000')]
    [TestCase('ReleaseTwoParts',  '1.2,1,2,0,5000')]
    [TestCase('AlphaWithNumber',  '0.1.2-alpha.2,0,1,2,2')]
    [TestCase('BetaWithNumber',   '0.1.2-beta.5,0,1,2,2005')]
    // no numeric segment - falls back to the release base (5000)
    [TestCase('AlphaNoNumber',    '1.2.3-alpha,1,2,3,5000')]
    [TestCase('BetaNoNumber',     '1.2.3-beta,1,2,3,5000')]
    // the largest values that fit
    [TestCase('MaxElements',      '65535.65535.65535,65535,65535,65535,5000')]
    [TestCase('AlphaMax',         '1.2.3-alpha.1999,1,2,3,1999')]
    [TestCase('BetaMax',          '1.2.3-beta.2999,1,2,3,4999')]
    [TestCase('AlphaLeadingZeros','1.2.3-alpha.0005,1,2,3,5')]
    // only all digit segments are numbers, 0x10 is not hex
    [TestCase('HexLikeSegment',   '1.2.3-alpha.0x10.7,1,2,3,7')]
    procedure ToFileVersion_maps_correctly(const version : string; const major, minor, release, build : Word);

    [TestCase('Release',          '1.2.3,1.2.3.5000')]
    [TestCase('AlphaWithNumber',  '0.1.2-alpha.2,0.1.2.2')]
    [TestCase('BetaWithNumber',   '0.1.2-beta.5,0.1.2.2005')]
    procedure ToFileVersionString_maps_correctly(const version : string; const expected : string);

    // raises rather than truncating to a Word, or overflowing into the next range.
    [TestCase('MajorTooLarge',      '65536.0.0')]
    [TestCase('MinorTooLarge',      '1.65536.0')]
    [TestCase('PatchTooLarge',      '1.0.65536')]
    [TestCase('AlphaTooLarge',      '1.2.3-alpha.2000')]
    [TestCase('BetaTooLarge',       '1.2.3-beta.3000')]
    [TestCase('BetaBeyondWord',     '1.2.3-beta.70000')]
    [TestCase('AlphaBeyondInteger', '1.2.3-alpha.3000000000')]
    procedure ToFileVersion_raises_when_out_of_range(const version : string);

  end;

implementation

uses
  System.SysUtils,
  VSoft.SemanticVersion;

{ TSemanticVersionTest }

procedure TSemanticVersionTest.Are_Equal(const a : string; const b : string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 = v2);
end;

procedure TSemanticVersionTest.Are_Not_Equal(const a : string; const b : string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 <> v2);
end;

procedure TSemanticVersionTest.Can_Create_Version_with_label;
var
  version : TSemanticVersion;
begin
  version := TSemanticVersion.Create(1,2,3,'Beta','');
  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);
  Assert.AreEqual(version.Patch,3);
  Assert.AreEqual(version.PreReleaseTag,'Beta');
  Assert.AreEqual<string>(version.ToString,'1.2.3-Beta');
end;

procedure TSemanticVersionTest.Can_Create_Version_with_label_and_metadata;
var
  version : TSemanticVersion;
begin
  version := TSemanticVersion.Create(1,2,3,'Beta','1.2.3.4');
  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);
  Assert.AreEqual(version.Patch,3);
  Assert.AreEqual(version.PreReleaseTag,'Beta');
  Assert.AreEqual(version.MetaData,'1.2.3.4');
  Assert.AreEqual<string>(version.ToString,'1.2.3-Beta+1.2.3.4');
end;

procedure TSemanticVersionTest.ToString_with_large_elements;
var
  version : TSemanticVersion;
begin
  version := TSemanticVersion.Create(1, 0, 4294967295);
  Assert.AreEqual('1.0.4294967295', version.ToString);
  Assert.AreEqual('1.0.4294967295', version.ToStringNoMeta);

  version := TSemanticVersion.Create(4294967295, 2147483648, 4294967295, 'beta', 'meta');
  Assert.AreEqual('4294967295.2147483648.4294967295-beta+meta', version.ToString);
  Assert.AreEqual('4294967295.2147483648.4294967295-beta', version.ToStringNoMeta);
end;

procedure TSemanticVersionTest.Can_Create_Version_with_three_components;
var
  version : TSemanticVersion;
begin
  version := TSemanticVersion.Create(1,2,3);
  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);
  Assert.AreEqual(version.Patch,3);
  Assert.AreEqual<string>(version.ToString,'1.2.3');
end;

procedure TSemanticVersionTest.Can_Create_Version_with_two_components;
var
  version : TSemanticVersion;
begin
  version := TSemanticVersion.Create(1,2);
  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);
  Assert.AreEqual(version.Patch,0);
  Assert.AreEqual<string>(version.ToString,'1.2.0');

end;

procedure TSemanticVersionTest.Can_Not_Parse_String_with_invalid_component;
var
  version : TSemanticVersion;
begin
  Assert.IsFalse(TSemanticVersion.TryParse('1.2.3.beta',version));
end;

procedure TSemanticVersionTest.Can_Not_Parse_String_with_invalid_major;
var
  version : TSemanticVersion;
begin
  Assert.IsFalse(TSemanticVersion.TryParse('x.0-beta',version));
end;

procedure TSemanticVersionTest.Can_Not_Parse_String_with_one_component;
var
  version : TSemanticVersion;
begin
  Assert.IsFalse(TSemanticVersion.TryParse('1',version));

end;

procedure TSemanticVersionTest.Can_Parse_String_with_label;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2.3-Beta',version));

  Assert.AreEqual(1,version.Major);
  Assert.AreEqual(2,version.Minor);
  Assert.AreEqual(3,version.Patch);
  Assert.AreEqual('Beta',version.PreReleaseTag);
end;

procedure TSemanticVersionTest.Can_Parse_String_with_label_and_metadata;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2.3-Beta+meta',version));

  Assert.AreEqual(1,version.Major);
  Assert.AreEqual(2,version.Minor);
  Assert.AreEqual(3,version.Patch);
  Assert.AreEqual('Beta',version.PreReleaseTag);
  Assert.AreEqual('meta',version.MetaData);

end;

procedure TSemanticVersionTest.Can_Parse_String_with_metadata;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2.3+meta',version));

  Assert.AreEqual(1,version.Major);
  Assert.AreEqual(2,version.Minor);
  Assert.AreEqual(3,version.Patch);
  Assert.AreEqual('',version.PreReleaseTag);
  Assert.AreEqual('meta',version.MetaData);
end;

procedure TSemanticVersionTest.Can_Parse_String_with_label_at_end(const version : string; const major, minor, patch : Cardinal; const preReleaseTag : string);
var
  v : TSemanticVersion;
  error : string;
begin
  Assert.IsTrue(TSemanticVersion.TryParseWithError(version, v, error), error);
  Assert.AreEqual<Cardinal>(major, v.Major);
  Assert.AreEqual<Cardinal>(minor, v.Minor);
  Assert.AreEqual<Cardinal>(patch, v.Patch);
  Assert.AreEqual(preReleaseTag, v.PreReleaseTag, false);
  Assert.AreEqual('', v.MetaData);
end;

procedure TSemanticVersionTest.Can_Parse_String_with_large_elements(const version : string; const major, minor, patch : Cardinal);
var
  v : TSemanticVersion;
  error : string;
begin
  Assert.IsTrue(TSemanticVersion.TryParseWithError(version, v, error), error);
  Assert.AreEqual<Cardinal>(major, v.Major);
  Assert.AreEqual<Cardinal>(minor, v.Minor);
  Assert.AreEqual<Cardinal>(patch, v.Patch);
end;

procedure TSemanticVersionTest.Can_Not_Parse_String_with_element_too_large(const version : string);
var
  v : TSemanticVersion;
  error : string;
begin
  Assert.IsFalse(TSemanticVersion.TryParseWithError(version, v, error));
  Assert.Contains(error, 'too large');
end;

procedure TSemanticVersionTest.Can_Not_Parse_String_with_dangling_separator(const version : string);
var
  v : TSemanticVersion;
  parsed : boolean;
begin
  parsed := TSemanticVersion.TryParse(version, v);
  Assert.IsFalse(parsed, 'parsed as ' + v.ToString);
end;

procedure TSemanticVersionTest.Can_Parse_String_with_three_components;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2.3',version));
  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);
  Assert.AreEqual(version.Patch,3);
end;

procedure TSemanticVersionTest.Can_Parse_String_with_two_components;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2',version));

  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);

end;

procedure TSemanticVersionTest.Comparisons(const a, b: string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 > v2);
  Assert.IsTrue(v2 < v1);
  Assert.IsFalse(v2 > v1);
  Assert.IsFalse(v1 < v2);
  Assert.AreEqual(v1, v1);
  Assert.AreEqual(v2, v2);
  Assert.AreNotEqual(v1, v2);

end;

procedure TSemanticVersionTest.Comparisons_with_large_elements(const aMajor, aMinor, aPatch, bMajor, bMinor, bPatch : Cardinal);
var
  v1, v2 : TSemanticVersion;
begin
  v1 := TSemanticVersion.Create(aMajor, aMinor, aPatch);
  v2 := TSemanticVersion.Create(bMajor, bMinor, bPatch);
  Assert.IsTrue(v1.CompareTo(v2) > 0);
  Assert.IsTrue(v2.CompareTo(v1) < 0);
  Assert.IsTrue(v1 > v2);
  Assert.IsTrue(v2 < v1);
  Assert.IsFalse(v2 > v1);
  Assert.IsFalse(v1 < v2);
  Assert.IsTrue(v1 >= v2);
  Assert.IsTrue(v2 <= v1);
  Assert.IsTrue(v1 <> v2);
  Assert.IsTrue(v1 = TSemanticVersion.Create(aMajor, aMinor, aPatch));
end;

procedure TSemanticVersionTest.ToFileVersion_maps_correctly(const version : string; const major, minor, release, build : Word);
var
  v : TSemanticVersion;
  fileVersion : TFileVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(version, v));
  fileVersion := v.ToFileVersion;
  Assert.AreEqual<Word>(major, fileVersion.Major);
  Assert.AreEqual<Word>(minor, fileVersion.Minor);
  Assert.AreEqual<Word>(release, fileVersion.Release);
  Assert.AreEqual<Word>(build, fileVersion.Build);
end;

procedure TSemanticVersionTest.ToFileVersionString_maps_correctly(const version : string; const expected : string);
var
  v : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(version, v));
  Assert.AreEqual<string>(expected, v.ToFileVersionString);
end;

procedure TSemanticVersionTest.ToFileVersion_raises_when_out_of_range(const version : string);
var
  v : TSemanticVersion;
begin
  v := TSemanticVersion.Parse(version);
  Assert.WillRaise(
    procedure
    begin
      v.ToFileVersion;
    end, EArgumentOutOfRangeException);
  Assert.WillRaise(
    procedure
    begin
      v.ToFileVersionString;
    end, EArgumentOutOfRangeException);
end;

procedure TSemanticVersionTest.GreaterThan(const a : string; const b : string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 > v2);

end;

procedure TSemanticVersionTest.GreaterThanEqualTo(const a : string; const b : string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 >= v2);

end;

procedure TSemanticVersionTest.LessThan(const a, b: string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 < v2);

end;

procedure TSemanticVersionTest.LessThanEqualTo(const a, b: string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsTrue(v1 <= v2);
end;

procedure TSemanticVersionTest.NotGreaterThan(const a : string; const b : string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsFalse(v1 > v2);
end;

procedure TSemanticVersionTest.NotGreaterThanEqualTo(const a : string; const b : string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsFalse(v1 >= v2);
end;

procedure TSemanticVersionTest.NotLessThan(const a, b: string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsFalse(v1 < v2);

end;

procedure TSemanticVersionTest.NotLessThanEqualTo(const a, b: string);
var
  v1, v2 : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse(a, v1));
  Assert.IsTrue(TSemanticVersion.TryParse(b, v2));
  Assert.IsFalse(v1 <= v2);

end;

procedure TSemanticVersionTest.Will_Fail_with_invalid_versions;
var
  v1 : TSemanticVersion;
begin
  Assert.IsFalse(TSemanticVersion.TryParse('sdfsdf', v1));
  Assert.IsFalse(TSemanticVersion.TryParse('1.2.3.4.5', v1));
  Assert.IsFalse(TSemanticVersion.TryParse('alphabeta.2.3', v1));
  Assert.IsFalse(TSemanticVersion.TryParse('1.2.A', v1));

end;

initialization
  TDUnitX.RegisterTestFixture(TSemanticVersionTest);
end.

