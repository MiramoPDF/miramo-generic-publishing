<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:miramo="http://ExternalFunction.miramo.com"
  exclude-result-prefixes="miramo"
  xmlns:mmc="http://www.miramo.com/mmc"
  >
  <xsl:output encoding="utf-8" indent="yes" />
  <!-- GLOBAL VARIABLES -->
  <!-- Multiplier used to convert dimensions to points (they are given as a proportion of a total of 606) -->
  <xsl:variable name="dmul">0.726</xsl:variable>
  <!-- Global bookname variable -->
  <xsl:variable name="bookName"><xsl:value-of select="/helpserver_display/folder/title"/></xsl:variable>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
  <!-- BOOK -->
  <xsl:template match="/">
  <MiramoXML>   
      <!-- Cover and TOC-->
      <Chapter>
        <VarDef varDef="vBookName"><xsl:value-of select="$bookName"/></VarDef>        
        <Section sectionDef="coverSection"/>
        <Section sectionDef="contentsSection"/>
        <!-- The text would normally come from a set of language strings in an XML file, or the XML input -->
        <P paraDef="H1TOC" >Table of Contents</P>
        <Contents contentsDef="contents"/>
      </Chapter>
    	<!-- Chapters -->
    	<xsl:apply-templates/>
  </MiramoXML>
  </xsl:template>
  
  <!-- lines element contents output as <Chapter> -->
  <xsl:template match="helpserver_display/folder/lines">
      <xsl:for-each select="*">
        <xsl:variable name="chapternum" select="count(preceding-sibling::*) + 1"/>
        <Chapter chapterNumberStart="{$chapternum}">
          <xsl:if test="$chapternum = 1"><xsl:attribute name="pageNumStart">1</xsl:attribute><xsl:attribute name="startSide">Right</xsl:attribute></xsl:if>
          <VarDef varDef="vBookName"><xsl:value-of select="$bookName"/></VarDef>        
          <Section sectionDef="firstSection"/>
          <xsl:apply-templates/>
        </Chapter>            
      </xsl:for-each> 
  </xsl:template>

  <!-- title element maps to <P> -->
  <xsl:template match="title">
  <!-- Derive paragraph format name from nest level of title element -->
    <xsl:variable name="paraDefName">Heading<xsl:value-of select="(count(ancestor::*) div 2) - 1"/>Auto</xsl:variable>
    <!-- Create P element unless the hidedes is false -->
    <xsl:if test="../@hidedes = 'false' and count(ancestor::*) &gt; 2">
    <P paraDef="{$paraDefName}">
      <!-- Heading2Auto headings usually start at top of page, but are overridden to have position="normal" 
      (start anywhere) override if it's within the first topic in the folder, or all previous topics have hidedes="true" -->	  
      <xsl:if test="$paraDefName='Heading2Auto'">
        <xsl:if test="count(../preceding-sibling::topic) = count(../preceding-sibling::topic[@hidedes='true'])">
          <xsl:attribute name="pgfPosition">normal</xsl:attribute>
        </xsl:if>
      </xsl:if>
      <!-- Create xref target if parent element has key attribute -->
      <xsl:if test="../@key"><MkDest id="{../@key}"/></xsl:if>
      <xsl:apply-templates/>
     </P>
    </xsl:if>

  </xsl:template>
  
  <!-- style element maps to <Font> -->
  <xsl:template match="style">
    <xsl:if test="@stylename">
      <Font fontDef="{@stylename}">
        <xsl:if test="@bo = 'true'"><xsl:attribute name="fontWeight">Bold</xsl:attribute></xsl:if>
        <xsl:apply-templates/><xsl:if test="../@key"><XRef xRefDef="onPage" id="{../@key}"/></xsl:if> 
      </Font>
    </xsl:if>
  </xsl:template>
  

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
  <!-- par element maps to <P> whose name is defined with @style-->
  <xsl:template match="par">
    <!-- paragraph format tag is determined by style attribute -->
    <P>
      <xsl:attribute name="paraDef">
        <xsl:if test="@style"><xsl:value-of select="@style"/></xsl:if>
        <xsl:if test="not(@style)">Body Text</xsl:if>
      </xsl:attribute>
      <xsl:if test="@spaceabove">
        <xsl:attribute name="spaceAbove"><xsl:value-of select="@spaceabove"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@spacebelow">
        <xsl:attribute name="spaceBelow"><xsl:value-of select="@spaceBelow"/></xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@align = 'center'">
          <xsl:attribute name="align">center</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <!-- If paragraph contains an image, set withPrevious=Y to keep with anchor paragraph -->
      <xsl:if test="child::image">
        <xsl:attribute name="withPrevious">Y</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
     </P>
  </xsl:template>
  
  <!-- Referenced image -->
  <xsl:template match="image">
    <!-- Shrink images to fit to maximum width of enclosing text frame, center horizontally. -->
      <AFrame wrapContent="Y" align="center" position="below" shrinkToFit="Y">
        <!-- apply scaling if given -->
        <xsl:variable name="s">
          <xsl:choose>
            <xsl:when test="@scale">
              <xsl:value-of select="@scale"/>
            </xsl:when>
            <xsl:otherwise>100</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>        
        <Image file="{@id}" width="{$s * @width div 100}px" height="{$s * @height div 100 }px"/>
      </AFrame>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
  <xsl:template match="table">
      <Tbl tblDef="{@rules}" tblWidth="column">
        <xsl:if test="@border-color">
          <xsl:attribute name="leftRule"><xsl:value-of select="@border-color"/></xsl:attribute>
          <xsl:attribute name="rightRule"><xsl:value-of select="@border-color"/></xsl:attribute>
          <xsl:attribute name="topRule"><xsl:value-of select="@border-color"/></xsl:attribute>
          <xsl:attribute name="bottomRule"><xsl:value-of select="@border-color"/></xsl:attribute>
       </xsl:if>
        <!-- Col widths are specified as a proportion of 606 ... for some reason.
        Convert values given to points by multiplying by $dmul.
        width=* means proportional width. --> 
        <xsl:for-each select="colgroup/col[@width]">
          <xsl:choose>
            <xsl:when test="@width = '*'">
              <TblColumn width="1*"/>
            </xsl:when>
            <xsl:otherwise><TblColumn width="{@width * $dmul}pt"/></xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates/>
      </Tbl>

  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
  <xsl:template match="tr">
    <Row>
      <xsl:choose>
        <xsl:when test="parent::tfoot">
          <xsl:attribute name="rowType">footer</xsl:attribute>
        </xsl:when>
        <xsl:when test="parent::thead">
          <xsl:attribute name="rowType">header</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <!-- Keep first and second table rows together -->
      <xsl:if test="count(preceding-sibling::tr) = 0">
        <xsl:attribute name="withNext">Y</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </Row>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
  <xsl:template match="td">
    <Cell>
        <xsl:if test="@background-color">
          <xsl:attribute name="fillColor">rgb(<xsl:value-of select="@background-color"/>)</xsl:attribute>            <xsl:attribute name="fillOpacity">100</xsl:attribute>
        </xsl:if>
      <xsl:if test="@valign = 'middle'">
        <xsl:attribute name="verticalTextAlign">M</xsl:attribute>
      </xsl:if>
      <xsl:if test="@colspan">
        <xsl:attribute name="columnSpan">
          <xsl:value-of select="@colspan"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@padding-top">
        <xsl:attribute name="topMargin">
          <xsl:value-of select="@padding-top"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@padding-left">
        <xsl:attribute name="leftMargin">
          <xsl:value-of select="@padding-top"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@rowspan">
        <xsl:attribute name="rowSpan">
          <xsl:value-of select="@rowspan"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </Cell>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -->
  <!-- pass <br/> through (linebreak) -->
  <xsl:template match="br">
    <xsl:copy-of select="." />
  </xsl:template>
  
  <!-- Discard content of unwanted elements -->
  <xsl:template match="head"/>
  
  <!-- Default is to process all other elements -->
   <xsl:template match="*">
    <xsl:apply-templates/>
   </xsl:template>
  
  <!-- Output paragraph text -->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>