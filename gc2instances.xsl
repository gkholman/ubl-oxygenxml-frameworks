<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:c="urn:X-Crane"
                exclude-result-prefixes="xs xsd c"
                version="2.0">

<xs:doc info="$Id: Crane-gc2instances.xsl,v 1.9 2017/05/10 23:30:30 admin Exp $"
        filename="Crane-gc2instances.xsl" vocabulary="DocBook">
  <xs:title>Create instances of mandatory elements</xs:title>
  <para>
    From the UBL CCTS model one can derive 
  </para>
</xs:doc>

<!--========================================================================-->
<xs:doc>
  <xs:title>Invocation parameters and input file</xs:title>
  <para>
    The main input file is the genericode of the CCTS model
  </para>
</xs:doc>

<xs:param name="common-library-singleton-model-name" ignore-ns="yes">
  <para>
    Use this parameter to identify the common library model name only when the
    common library consists of only a single ABIE.  If the common library
    contains more than one ABIE then it will be automatically detected. Note
    that there cannot be more than one common library, that is, a model with
    more than one ABIE.
  </para>
</xs:param>
<xsl:param name="common-library-singleton-model-name"
           as="xsd:string?" select="()"/>

<xs:param ignore-ns='yes'>
  <para>
    The namespace of the document element.  If the string contains the
    sequence "%n", that is replaced with the component name of the model
    being processed.
  </para>
</xs:param>
<xsl:param name="dabie-ns" as="xsd:string" 
           select="'urn:oasis:names:specification:ubl:schema:xsd:%n-2'"/>

<xs:param ignore-ns='yes'>
  <para>
    The namespace of the library aggregates.
  </para>
</xs:param>
<xsl:param name="asbie-ns" as="xsd:string" 
           select=
"'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2'"/>

<xs:param ignore-ns='yes'>
  <para>
    The namespace of the library basics.
  </para>
</xs:param>
<xsl:param name="bbie-ns" as="xsd:string" 
           select=
"'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'"/>

<xs:param ignore-ns='yes'>
  <para>
    The namespace of the extension metadata.
  </para>
</xs:param>
<xsl:param name="ext-ns" as="xsd:string" 
           select=
"'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2'"/>

<xs:param ignore-ns='yes'>
  <para>
    The prefix of the library aggregates namespace.
  </para>
</xs:param>
<xsl:param name="asbie-prefix" as="xsd:string" select="'cac'"/>

<xs:param ignore-ns='yes'>
  <para>
    The prefix of the library basics namespace.
  </para>
</xs:param>
<xsl:param name="bbie-prefix" as="xsd:string" select="'cbc'"/>

<xs:param ignore-ns='yes'>
  <para>
    The prefix of the extension metadata namespace.
  </para>
</xs:param>
<xsl:param name="ext-prefix" as="xsd:string" select="'ext'"/>

<xs:param ignore-ns='yes'>
  <para>
    The output name template for the empty generated files
  </para>
</xs:param>
<xsl:param name="output-name-empty-template" as="xsd:string" required="yes"/>

<xs:param ignore-ns='yes'>
  <para>
    The output name template for the stuffed generated files
  </para>
</xs:param>
<xsl:param name="output-name-stuffed-template" as="xsd:string" required="yes"/>

<xs:param ignore-ns='yes'>
  <para>
    The output name for the generated NVDL file
  </para>
</xs:param>
<xsl:param name="output-name-nvdl" as="xsd:string" required="yes"/>

<xs:param ignore-ns='yes'>
  <para>
    The reference template for the schemas relative to the NVDL file
  </para>
</xs:param>
<xsl:param name="nvdl-schema-template" as="xsd:string" required="yes"/>

<xs:param ignore-ns='yes'>
  <para>
    The output name for the generated Schematron file
  </para>
</xs:param>
<xsl:param name="output-name-schematron" as="xsd:string" required="yes"/>

<xs:param ignore-ns='yes'>
  <para>
    The version string to stamp generated artefacts
  </para>
</xs:param>
<xsl:param name="package-version" as="xsd:string" required="yes"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Globals</xs:title>
</xs:doc>

<xs:output>
  <para>Don't indent the output; because own indentation being used</para>
</xs:output>
<xsl:output indent="no"/>

<xs:key>
  <para>Keep track of CCTS items by class</para>
</xs:key>
<xsl:key name="c:bieByClass"
         match="Row"
         use="Value[@ColumnRef='ObjectClass']/SimpleValue"/>

<xs:variable>
  <para>Keep track of name columns</para>
</xs:variable>
<xsl:variable name="c:names" as="xsd:string+"
              select="('UBLName','ComponentName')"/>

<xs:function>
  <para>Obtain a piece of information from a genericode column</para>
  <xs:param name="c:row">
    <para>From this row.</para>
  </xs:param>
  <xs:param name="c:col">
    <para>At this column name.</para>
  </xs:param>
</xs:function>
<xsl:function name="c:col" as="element(SimpleValue)?">
  <xsl:param name="c:row" as="element(Row)"/>
  <xsl:param name="c:col" as="xsd:string+"/>
  <xsl:sequence select="$c:row/Value[@ColumnRef=$c:col]/SimpleValue"/>
</xsl:function>

<!--========================================================================-->
<xs:doc>
  <xs:title>Getting started</xs:title>
</xs:doc>

<xs:template>
  <para>
    For each of the models, create the instance.
  </para>
</xs:template>
<xsl:template match="/">
  <xsl:for-each-group select="/*/SimpleCodeList/Row"
                      group-by="c:col(.,'ModelName')">
    <xsl:variable name="c:modelName" select="c:col(.,'ModelName')"/>
    <xsl:if test="count(current-group()[c:col(.,'ComponentType')='ABIE']) = 1
                  or $c:modelName != $common-library-singleton-model-name">
      <!--then this is a document model and not the common library-->
      <xsl:variable name="c:className" select="c:col(.,'ObjectClass')"/>
      <xsl:variable name="c:documentElementName"
                    select="current-group()[c:col(.,'ComponentType')='ABIE']/
                            c:col(.,$c:names)"/>
      <xsl:result-document href="{replace($output-name-stuffed-template,
                                          '%n',$c:documentElementName)}">
        <xsl:text>&#xa;</xsl:text>
        <xsl:element name="{$c:documentElementName}"
                  namespace="{replace($dabie-ns,'%n',$c:documentElementName)}">
          <xsl:namespace name="{$asbie-prefix}" select="$asbie-ns"/>
          <xsl:namespace name="{$bbie-prefix}" select="$bbie-ns"/>
          <xsl:namespace name="{$ext-prefix}" select="$ext-ns"/>

          <xsl:call-template name="c:doMandatoryChildren">
            <xsl:with-param name="c:className" select="$c:className"/>
            <xsl:with-param name="c:stuffBBIEs" select="true()" tunnel="yes"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:result-document>
      <xsl:result-document href="{replace($output-name-empty-template,
                                          '%n',$c:documentElementName)}">
        <xsl:text>&#xa;</xsl:text>
        <xsl:element name="{$c:documentElementName}"
                  namespace="{replace($dabie-ns,'%n',$c:documentElementName)}">
          <xsl:namespace name="{$asbie-prefix}" select="$asbie-ns"/>
          <xsl:namespace name="{$bbie-prefix}" select="$bbie-ns"/>
          <xsl:namespace name="{$ext-prefix}" select="$ext-ns"/>

          <xsl:call-template name="c:doMandatoryChildren">
            <xsl:with-param name="c:className" select="$c:className"/>
            <xsl:with-param name="c:stuffBBIEs" select="false()" tunnel="yes"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:result-document>
    </xsl:if>
  </xsl:for-each-group>
  
  <xsl:call-template name="c:generateNVDLoutput"/>
  <xsl:call-template name="c:generateSchematronOutput"/>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Getting started</xs:title>
</xs:doc>

<xs:template>
  <para>
    For a given class, do the mandatory children
  </para>
  <xs:param name="c:className">
    <para>Children of which class?</para>
  </xs:param>
  <xs:param name="c:stuffBBIEs">
    <para>Indication of stuffing the BBIEs with content.</para>
  </xs:param>
  <xs:param name="c:depth">
    <para>Depth for indentation</para>
  </xs:param>
</xs:template>
<xsl:template name="c:doMandatoryChildren">
  <xsl:param name="c:className" as="xsd:string" required="yes"/>
  <xsl:param name="c:stuffBBIEs" as="xsd:boolean" tunnel="yes"/>
  <xsl:param name="c:depth" as="xsd:integer" select="1"/>
  <xsl:for-each select="key('c:bieByClass',$c:className)">
    <!--walk through the children-->
    <xsl:if test="starts-with(c:col(.,'Cardinality'),'1')">
      <!--indent at current level-->
      <xsl:text>&#xa;</xsl:text>
      <xsl:for-each select="1 to $c:depth">
        <xsl:text>  </xsl:text>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="c:col(.,'ComponentType')='BBIE'">
          <!--time to make a leaf-->
          <xsl:element name="{concat($bbie-prefix,':',c:col(.,$c:names))}"
                       namespace="{$bbie-ns}">
            <xsl:variable name="c:representation"
                          select="c:col(.,'RepresentationTerm')"/>
            <xsl:choose>
              <xsl:when test="not($c:stuffBBIEs)">
                <!--then leave the element empty-->
              </xsl:when>
              <xsl:when test="$c:representation='Amount'">
                <xsl:attribute name="currencyID">ZZZ</xsl:attribute>
                <xsl:text>0.000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Binary Object'">
                <xsl:attribute name="mimeCode">ZZZ</xsl:attribute>
              </xsl:when>
              <xsl:when test="$c:representation='Code'">
                <xsl:text>ZZZ</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='DateTime'">
                <xsl:text>2000-01-01T00:00:00+0000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Date'">
                <xsl:text>2000-01-01</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Time'">
                <xsl:text>00:00:00+0000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Identifier'">
                <xsl:text>ZZZ</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Indicator'">
                <xsl:text>false</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Measure'">
                <xsl:attribute name="unitCode">ZZZ</xsl:attribute>
                <xsl:text>000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Numeric'">
                <xsl:text>000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Percent'">
                <xsl:text>000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Rate'">
                <xsl:text>000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Quantity'">
                <xsl:text>000</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Text'">
                <xsl:text>ZZZ</xsl:text>
              </xsl:when>
              <xsl:when test="$c:representation='Name'">
                <xsl:text>ZZZ</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <!--time to make a branch-->
          <xsl:element name="{concat($asbie-prefix,':',c:col(.,$c:names))}"
                       namespace="{$asbie-ns}">
            <xsl:call-template name="c:doMandatoryChildren">
              <xsl:with-param name="c:className"
                              select="c:col(.,'AssociatedObjectClass')"/>
              <xsl:with-param name="c:depth" select="$c:depth + 1"/>
            </xsl:call-template>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:for-each>
  <!--indent at current level-->
  <xsl:text>&#xa;</xsl:text>
  <xsl:for-each select="2 to $c:depth">
    <xsl:text>  </xsl:text>
  </xsl:for-each>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>NVDL</xs:title>
</xs:doc>

<xs:template>
  <para>
    Synthesize the required NVDL schema
  </para>
</xs:template>
<xsl:template name="c:generateNVDLoutput">
  <xsl:result-document href="{$output-name-nvdl}">
      <xsl:comment>
A generated NVDL schema despatching to all possible schemas.

Version: <xsl:value-of select="$package-version"/><xsl:text>
</xsl:text>
      </xsl:comment>
<rules xmlns="http://purl.oclc.org/dsdl/nvdl/ns/structure/1.0"
       startMode="top-level">
  <mode name="top-level">
    <xsl:for-each-group select="/*/SimpleCodeList/Row"
                        group-by="c:col(.,'ModelName')">
      <xsl:variable name="c:modelName" select="c:col(.,'ModelName')"/>
      <xsl:if test="count(current-group()[c:col(.,'ComponentType')='ABIE']) = 1
                    or $c:modelName != $common-library-singleton-model-name">
        <!--then this is a document model and not the common library-->
        <xsl:variable name="c:documentElementName"
                      select="current-group()[c:col(.,'ComponentType')='ABIE']/
                              c:col(.,$c:names)"/>
        <namespace ns="{replace($dabie-ns,'%n',$c:documentElementName)}">
          <validate schema="{replace($nvdl-schema-template,
                                     '%n',$c:documentElementName)}"
                    useMode="descendants"/>
        </namespace>
      </xsl:if>
    </xsl:for-each-group>
  </mode>
  <mode name="descendants">
    <xsl:for-each select="$asbie-ns,$bbie-ns,$ext-ns">
      <namespace ns="{.}">
        <attach/>
      </namespace>
    </xsl:for-each>
     <anyNamespace>
       <attachPlaceholder/>
     </anyNamespace>
  </mode>
</rules>
  </xsl:result-document>
</xsl:template>  

<!--========================================================================-->
<xs:doc>
  <xs:title>Schematron</xs:title>
</xs:doc>

<xs:template>
  <para>
    Synthesize the required Schematron schema
  </para>
</xs:template>
<xsl:template name="c:generateSchematronOutput">
  <xsl:result-document href="{$output-name-schematron}">
    <schema xmlns="http://purl.oclc.org/dsdl/schematron"
            queryBinding="xslt2">
      <ns prefix="{$bbie-prefix}" uri="{$bbie-ns}"/>
      <ns prefix="{$ext-prefix}" uri="{$ext-ns}"/>
      
      <xsl:comment>
An encoding of the Additional Document Constraints found at:
http://docs.oasis-open.org/ubl/os-UBL-2.1/UBL-2.1.html#S-ADDITIONAL-DOCUMENT-CONSTRAINTS

Note that [IND1] is addressed by having validated the document with the schema,
and that [IND2] and [IND3] are constraints that cannot be tested within an
XML processor.

Version: <xsl:value-of select="$package-version"/><xsl:text>
</xsl:text>
      </xsl:comment>
      <pattern>
         <rule context="ext:*[* except ext:*]//*">
           <xsl:comment select="'no constraints'"/>
         </rule>
        <rule context="*[not(*)]">
          <assert test="normalize-space(.)"
            >UBL rule [IND5] states that elements cannot be void of content.
</assert>
        </rule>
      </pattern>
      
      <pattern>
        <rule context="@*[normalize-space(.)='']">
          <assert test="normalize-space(.)"
            >UBL rule [IND5] infers that attributes cannot be void of content.
</assert>
        </rule>
      </pattern>

      <pattern>
        <rule context="*[@languageID]">
          <!--check using string() to equate absent with empty-->
          <assert test="not(../(* except current())[name(.)=name(current())]
                          [string(@languageID)=string(current()/@languageID)])"
>UBL rule [IND7] states that two sibling elements of the same name cannot have the same languageID= attribute value
</assert>
        </rule>
        <xsl:variable name="c:textBBIEnames" as="xsd:string*">
        <xsl:for-each-group select="/*/SimpleCodeList/Row"
                            group-by="c:col(.,'ModelName')">
          <xsl:variable name="c:modelName" select="c:col(.,'ModelName')"/>
      <xsl:if test="count(current-group()[c:col(.,'ComponentType')='ABIE'])>1
                    or $c:modelName = $common-library-singleton-model-name">
        <!--then this is the common library-->
        <xsl:for-each-group group-by="c:col(.,$c:names)"
                     select="current-group()[c:col(.,'ComponentType')='BBIE']">
          <xsl:sort select="c:col(.,$c:names)"/>
          <!--look at all of the BBIEs with the same name-->
          <xsl:variable name="c:bbieTypes" as="xsd:string*"
      select="distinct-values(current-group()/c:col(.,'RepresentationTerm'))"/>
          <xsl:if test="some $c:type in $c:bbieTypes 
                        satisfies $c:type='Text'">
            <xsl:if test="count($c:bbieTypes)>1">
              <xsl:message terminate="yes">
          <xsl:text>The code needs to be upgraded to accommodate </xsl:text>
          <xsl:text>non-homogenous types for the element named: </xsl:text>
                <xsl:value-of select="c:col(.,$c:names)"/>
              </xsl:message>
            </xsl:if>
            <xsl:value-of select="c:col(.,$c:names)"/>
          </xsl:if>
        </xsl:for-each-group>
      </xsl:if>
        </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="count($c:textBBIEnames)">
          <rule>
            <xsl:attribute select="for $c:name in $c:textBBIEnames
                                   return concat($bbie-prefix,':',$c:name)"
                           separator=" | " name="context"/>
            <assert test="not(../(* except current())[name(.)=name(current())][not(@languageID)])">
>UBL rule [IND8] states that two sibling elements of the same name cannot both omit the languageID= attribute
</assert>
          </rule>
        </xsl:if>
      </pattern>
    </schema>
  </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
