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

    procedure Can_Create_Version_with_four_components;

    procedure Can_Parse_String_with_two_components;

    procedure Can_Parse_String_with_three_components;

    procedure Can_Parse_String_with_four_components;

    procedure Can_Not_Parse_String_with_one_component;

    procedure Can_Not_Parse_String_with_invalid_component;

    procedure Can_Not_Parse_String_with_invalid_major;


    procedure Are_Equal_1;

    procedure Are_Not_Equal;

    procedure IsGreaterThan;

    procedure IsGreaterThanEqualTo;

    procedure IsLessThan;

    procedure IsLessThanOrEqualTo;

  end;

implementation

uses
  VSoft.SemanticVersion;

{ TSemanticVersionTest }

procedure TSemanticVersionTest.Are_Equal_1;
var
  v1, v2 : TSemanticVersion;
begin
  v1 := TSemanticVersion.Create(1,2);
  v2 := TSemanticVersion.Create(1,2);
  Assert.IsTrue(v1 = v2);


end;

procedure TSemanticVersionTest.Are_Not_Equal;
var
  v1, v2 : TSemanticVersion;
begin
  v1 := TSemanticVersion.Create(1,2);
  v2 := TSemanticVersion.Create(1,2,3);
  Assert.IsTrue(v1 <> v2);
end;

procedure TSemanticVersionTest.Can_Create_Version_with_four_components;
var
  version : TSemanticVersion;
begin
  version := TSemanticVersion.Create(1,2,3,'Beta');
  Assert.AreEqual(version.Major,1);
  Assert.AreEqual(version.Minor,2);
  Assert.AreEqual(version.Patch,3);
  Assert.AreEqual(version.PreReleaseLabel,'Beta');
  Assert.AreEqual<string>(version.ToString,'1.2.3-Beta');
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

procedure TSemanticVersionTest.Can_Parse_String_with_four_components;
var
  version : TSemanticVersion;
begin
  Assert.IsTrue(TSemanticVersion.TryParse('1.2.3-Beta',version));

  Assert.AreEqual(1,version.Major);
  Assert.AreEqual(2,version.Minor);
  Assert.AreEqual(3,version.Patch);
  Assert.AreEqual('Beta',version.PreReleaseLabel);
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

procedure TSemanticVersionTest.IsGreaterThan;
var
  v1, v2 : TSemanticVersion;
begin
  v1 := TSemanticVersion.Create(1,3);
  v2 := TSemanticVersion.Create(1,2);
  Assert.IsTrue(v1 > v2);

  v1 := TSemanticVersion.Create(1,2,1);
  Assert.IsTrue(v1 > v2);

end;

procedure TSemanticVersionTest.IsGreaterThanEqualTo;
var
  v1, v2 : TSemanticVersion;
begin
  //test equal case
  v1 := TSemanticVersion.Create(1,3);
  v2 := TSemanticVersion.Create(1,3);
  Assert.IsTrue(v1 >= v2);

  v1 := TSemanticVersion.Create(1,3,1);
  v2 := TSemanticVersion.Create(1,3,1);
  Assert.IsTrue(v1 >= v2);

  v1 := TSemanticVersion.Create(1,3,1,'Beta');
  v2 := TSemanticVersion.Create(1,3,1,'Alpha');
  Assert.IsTrue(v1 >= v2);


  //test gt case
  v1 := TSemanticVersion.Create(1,3,1,'Beta');
  v2 := TSemanticVersion.Create(1,3,1,'Alpha');
  Assert.IsTrue(v1 >= v2);

  v1 := TSemanticVersion.Create(1,3,2);
  v2 := TSemanticVersion.Create(1,3,1);
  Assert.IsTrue(v1 >= v2);

  v1 := TSemanticVersion.Create(1,3);
  v2 := TSemanticVersion.Create(1,2);
  Assert.IsTrue(v1 >= v2);

  v1 := TSemanticVersion.Create(2,0);
  v2 := TSemanticVersion.Create(1,2);
  Assert.IsTrue(v1 >= v2);

end;

procedure TSemanticVersionTest.IsLessThan;
var
  v1, v2 : TSemanticVersion;
begin
  v1 := TSemanticVersion.Create(1,2);
  v2 := TSemanticVersion.Create(1,3);
  Assert.IsTrue(v1 < v2);

  v2 := TSemanticVersion.Create(1,2,1);
  Assert.IsTrue(v1 < v2);
end;

procedure TSemanticVersionTest.IsLessThanOrEqualTo;
var
  v1, v2 : TSemanticVersion;
begin
  //test equal case
  v1 := TSemanticVersion.Create(1,3);
  v2 := TSemanticVersion.Create(1,3);
  Assert.IsTrue(v1 <= v2);

  v1 := TSemanticVersion.Create(1,3,1);
  v2 := TSemanticVersion.Create(1,3,1);
  Assert.IsTrue(v1 <= v2);

  v1 := TSemanticVersion.Create(1,3,1,'Beta');
  v2 := TSemanticVersion.Create(1,3,1,'Beta');
  Assert.IsTrue(v1 <= v2);


  //test lt case
  v1 := TSemanticVersion.Create(1,3,1,'Alpha');
  v2 := TSemanticVersion.Create(1,3,1,'Alpha');
  Assert.IsTrue(v1 <= v2);

  v1 := TSemanticVersion.Create(1,3,1);
  v2 := TSemanticVersion.Create(1,3,2);
  Assert.IsTrue(v1 <= v2);

  v1 := TSemanticVersion.Create(1,2);
  v2 := TSemanticVersion.Create(1,3);
  Assert.IsTrue(v1 <= v2);

  v1 := TSemanticVersion.Create(1,0);
  v2 := TSemanticVersion.Create(2,2);
  Assert.IsTrue(v1 <= v2);
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

