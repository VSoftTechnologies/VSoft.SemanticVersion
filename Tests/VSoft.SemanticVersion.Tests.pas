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


    procedure Can_Parse_String_with_two_components;

    procedure Can_Parse_String_with_three_components;

    procedure Can_Parse_String_with_label;

    procedure Can_Parse_String_with_label_and_metadata;

    procedure Can_Parse_String_with_metadata;

    procedure Can_Not_Parse_String_with_one_component;

    procedure Can_Not_Parse_String_with_invalid_component;

    procedure Can_Not_Parse_String_with_invalid_major;


    [TestCase('Case1','1.2.3,1.2.3')]
    procedure Are_Equal(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.0')]
    procedure Are_Not_Equal(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.2')]
    [TestCase('Case2','1.2.3,1.1.3')]
    [TestCase('Case3','1.2.3,0.2.3')]
    procedure GreaterThan(const a : string; const b : string);


    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case2','1.2.3,1.2.2')]
    [TestCase('Case3','1.2.3,1.1.3')]
    [TestCase('Case4','1.2.3,0.2.3')]
    procedure GreaterThanEqualTo(const a : string; const b : string);

    [TestCase('Case1','1.2.3,1.2.3')]
    [TestCase('Case1','1.2.3,1.2.4')]
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
    [TestCase('Case1','1.2.3,1.2.2')]
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
    [TestCase('Case17','2.0.0,1.2.3')]
    [TestCase('Case18','1.2.3,1.2.3-asdf')]
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
    procedure Comparisons(const a : string; const b : string);

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
  Assert.AreEqual(version.PreReleaseLabel,'Beta');
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
  Assert.AreEqual(version.PreReleaseLabel,'Beta');
  Assert.AreEqual(version.MetaData,'1.2.3.4');
  Assert.AreEqual<string>(version.ToString,'1.2.3-Beta+1.2.3.4');
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
  Assert.AreEqual('Beta',version.PreReleaseLabel);
end;

procedure TSemanticVersionTest.Can_Parse_String_with_label_and_metadata;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2.3-Beta+meta',version));

  Assert.AreEqual(1,version.Major);
  Assert.AreEqual(2,version.Minor);
  Assert.AreEqual(3,version.Patch);
  Assert.AreEqual('Beta',version.PreReleaseLabel);
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
  Assert.AreEqual('',version.PreReleaseLabel);
  Assert.AreEqual('meta',version.MetaData);
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

end;

initialization
  TDUnitX.RegisterTestFixture(TSemanticVersionTest);
end.

