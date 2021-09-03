<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:c="urn:X-Crane"
                exclude-result-prefixes="xs xsd c"
                version="2.0">

<xs:doc info="$Id: Crane-gc2framework.xsl,v 1.3 2017/04/14 17:09:53 admin Exp $"
        filename="Crane-gc2instances.xsl" vocabulary="DocBook">
  <xs:title>Update oXygen association rules</xs:title>
  <para>
    From the UBL CCTS model one can massage a framework to include
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

<xs:variable ignore-ns='yes'>
  <para>
    The namespace of the document element.  If the string contains the
    sequence "%n", that is replaced with the component name of the model
    being processed.
  </para>
</xs:variable>
<xsl:variable name="c:gc" as="document-node()" select="document($gc-uri,/)"/>

<xs:param ignore-ns='yes'>
  <para>
    The pointer to the genericode of the 
  </para>
</xs:param>
<xsl:param name="gc-uri" as="xsd:string" required="yes"/>

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
    The version string of UBL
  </para>
</xs:param>
<xsl:param name="ubl-version" as="xsd:string" required="yes"/>

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
  <para>Indent the output</para>
</xs:output>
<xsl:output indent="yes"/>

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
  <para>Root work</para>
</xs:template>
<xsl:template match="/">
  <!--not a show-stopper, so build the result-->
  <xsl:apply-templates/>
</xsl:template>

<xs:template>
  <para>
    For each of the models, create the instance.
  </para>
</xs:template>
<xsl:template match="field[@name='doctypeRules']">
  <xsl:if test="not($c:gc/*/SimpleCodeList)">
    <xsl:message terminate="yes">
      <xsl:text>Given genericode file not found or not appropriate: </xsl:text>
      <xsl:value-of select="$gc-uri"/>
    </xsl:message>
  </xsl:if>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
  <xsl:variable name="c:rule"
                select="(documentTypeRule-array/documentTypeRule)[1]"/>
  <documentTypeRule-array>
    <xsl:for-each-group select="$c:gc/*/SimpleCodeList/Row"
                        group-by="c:col(.,'ModelName')">
      <xsl:variable name="c:modelName" select="c:col(.,'ModelName')"/>
      <xsl:if test="count(current-group()[c:col(.,'ComponentType')='ABIE']) = 1
                    or $c:modelName != $common-library-singleton-model-name">
        <!--then this is a document model and not the common library-->
        <xsl:apply-templates select="$c:rule" mode="c:rule">
          <xsl:with-param name="c:nsSubstitutionElementName" tunnel="yes"
                      select="current-group()[c:col(.,'ComponentType')='ABIE']/
                              c:col(.,$c:names)"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:for-each-group>
  </documentTypeRule-array>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>
    Modify the namespace value for the rule.
  </para>
  <xs:param name="c:documentElementName">
    <para>The name to substitute into the namespace string</para>
  </xs:param>
</xs:template>
<xsl:template match="field[@name='namespace']/String" priority="1"
              mode="c:rule">
  <xsl:param name="c:nsSubstitutionElementName" as="xsd:string"
             tunnel="yes"/>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:value-of
                select="replace($dabie-ns,'%n',$c:nsSubstitutionElementName)"/>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>
    For each of the models, create the instance.
  </para>
</xs:template>
<xsl:template match="String">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:value-of select="replace(replace(.,'%v',$ubl-version),
                                            '%p',$package-version)"/>
  </xsl:copy>
</xsl:template>
  
<!--========================================================================-->
<xs:doc>
  <xs:title></xs:title>
</xs:doc>

<xs:template>
  <para>
    The identity template is used to copy all nodes not already being handled
    by other template rules.
  </para>
</xs:template>
<xsl:template match="@*|node()" mode="#all">
  <xsl:copy>
    <xsl:apply-templates mode="#current" select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
