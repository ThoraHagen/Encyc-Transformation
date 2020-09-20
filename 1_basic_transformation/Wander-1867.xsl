<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Wander-1867-000.xml')"> </xsl:variable>
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:import href="preface.xsl"/>

    <!-- ________________________Basic TEI Structure________________________ -->

    <xsl:template match="/">
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:value-of select="$file//META/DEFSERVER/TITLE"/>
                        </title>
                        <author>
                            <xsl:value-of select="$file/doc//div[@class = 'zenoCOTitles']/h3[1]"/>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <publisher/>
                        <date>
                            <xsl:value-of select="$file/doc/META/DEFSERVER/YEARS"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <xsl:for-each select="$file/doc/META/DEFBOOK/BOOKCITE">
                                <title>
                                    <xsl:apply-templates/>
                                </title>
                            </xsl:for-each>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <front>
                    <div type="mainpage">
                        <div type="title">
                            <xsl:for-each
                                select="$file//articlegroup[@name = '-']//h1 | $file//articlegroup[@name = '-']//h2 | $file//articlegroup[@name = '-']//h3">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select="$file//articlegroup[@name = '-']//text//p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <xsl:apply-templates select="$file//articlegroup[@name = 'M']/article" mode="preface"/>
                </front>
                <body>
                    <div>
                        <xsl:apply-templates/>
                    </div>
                </body>
                <back> </back>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="$file//articlegroup[@name = 'M']/article" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>
    
    <xsl:template match="article/text" mode="preface">
        <xsl:apply-templates mode="preface"/>
    </xsl:template>
    
    <xsl:template match="h5|h6" mode="preface">
        <p>
        <xsl:apply-templates mode="preface"/>
        </p>
    </xsl:template>
    
    <xsl:template match="$file//plink[(not(parent::p/parent::text/parent::article/lem/string-join(text()) eq 'Anmerkungen')
        and (not(parent::p/parent::text/parent::article/lem/string-join(text()) eq 'Verwandte Sprichwörter und Redensarten')))]">
        <xsl:variable name="lem" select="translate(./parent::p/parent::text/parent::article/lem/text(), ' ()', '')"/>
        <xsl:variable name="number" select="translate(./sup/text(), ' ', '')"/>
        <ref type='footnote' target="{replace(concat('#', $lem, $number), '\n', '')}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
    
    <xsl:template match="$file//article[./lem/text() eq 'Anmerkungen']/text" mode='preface'>
            <head>Anmerkungen</head>
        <xsl:for-each-group select="p" group-starting-with="p[plink]">
            <xsl:variable name="lem" select="translate(replace(current-group()[1]//plink/@href, '.*Nachworte/|#.*', ''), ' ', '')"/>
            <xsl:variable name="number" select="translate(string-join(current-group()[1]//plink//(text())), ' ', '')"/>
            <note type='footnote' xml:id="{replace(translate(concat($lem, $number), ' ()', ''), '\n', '')}">
                    <xsl:for-each select="current-group()[self::p]">
                        <p>
                        <xsl:apply-templates select="."/>
                        </p>
                    </xsl:for-each> 
            </note>
        </xsl:for-each-group>
        
    </xsl:template>

    <!-- ________________________Footnote handling________________________  -->

    <!-- h4 with ['Zusätze und Ergänzungen] indicates following footnotes-->
    <!-- footnotes are grouped and moved to the end of the entry -->
    <!-- after these footnotes, the entry might continue -->
    
    <xsl:template match="text">
          <xsl:for-each-group select="*" group-starting-with="//br|h4|startpage|page|sigel|p[plink[b]]">
                    <def>
                        <xsl:for-each select="current-group()[self::p]">
                            <p><xsl:apply-templates/></p>
                        </xsl:for-each>
                    </def>
                </xsl:for-each-group>
    </xsl:template>
    
   
   <xsl:template match="plink[parent::p[preceding-sibling::h4]]">
       <xsl:variable name="lemma"
           select="translate(./ancestor::article//lem/text(), ' []:-();,', '')"/>
       <xsl:variable name="apos">'</xsl:variable>
       <xsl:variable name="lem" select='translate($lemma, $apos, "")'/>
       <xsl:variable name="fnnumber"
           select="translate(./b/text(), ' []:-.*();,', '')"/>
       <ref type='temp' xml:id="{concat($lem,'.', $fnnumber)}'">
           <xsl:apply-templates/>
       </ref>
   </xsl:template>
    <!--<xsl:template match="h4[following-sibling::p[plink]]" priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article//lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="lem" select='translate($lemma, $apos, "")'/>
        <xsl:for-each select="./preceding-sibling::p">
            <def>
                <xsl:apply-templates/>
            </def>
        </xsl:for-each>
        <xsl:for-each select="./following-sibling::p[not(plink) and not(preceding-sibling::br[1]/following-sibling::p[plink])]">
            <def>
                <xsl:apply-templates/>
            </def>
        </xsl:for-each>
        <note>
            <xsl:for-each-group select="./following-sibling::p | ./following-sibling::br"
                group-ending-with="br">
                <xsl:variable name="fnnumber"
                    select="translate(.//plink/b/text(), ' []:-.*();,', '')"/>
                <xsl:if test="not($fnnumber eq '')">
                    <note type="footnote" xml:id="{concat($lem,'.', $fnnumber)}">
                        <xsl:for-each select="current-group()[self::p]">
                            <xsl:apply-templates/>
                        </xsl:for-each>
                    </note>
                </xsl:if>
            </xsl:for-each-group>
        </note>
    </xsl:template>

    <xsl:template match="article[descendant::h4]//p" priority="5"/>

    <xsl:template match="h4">
        <!-\- no references to these footnotes-\->
        <xsl:variable name="lemma"
            select="translate(./ancestor::article//lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="lem" select='translate($lemma, $apos, "")'/>

        <!-\- additions are moved -\->
        <xsl:for-each select="./preceding-sibling::p">
            <def>
                <xsl:apply-templates/>
            </def>
        </xsl:for-each>
        <note>
            <xsl:for-each-group select="./following-sibling::p | ./following-sibling::br"
                group-ending-with="br">
                <!-\- xml:id via position() -> no references within the entry anyways -\->
                <xsl:variable name="fnnumber" select="position()"/>
                <note type="footnote" xml:id="{concat($lem,'.', $fnnumber)}">
                    <xsl:for-each select="current-group()[self::p]">
                        <xsl:apply-templates/>
                    </xsl:for-each>
                </note>
            </xsl:for-each-group>
        </note>
    </xsl:template>-->

    <xsl:template match="plink[parent::p[following-sibling::h4] and not(child::ls)]" priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article//lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="fnnumber" select="translate(./b/text(), ' []:-.();,*', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="lem" select='translate($lemma, $apos, "")'/>
        <ref type='footnote' target="{concat('#', $lem,'.', $fnnumber)}">
        <xsl:apply-templates/>
        </ref>
    </xsl:template>
  

    <xsl:template match="plink[child::ls]" priority="2">
        <xsl:variable name="lemma" select="replace(./@href, '/.*/', '')"/>
        <ref type="entry" target="{$lemma}"/>
    </xsl:template>

    <!-- ________________________Austern exception________________________ -->

    <!-- 2 times 'Zusätze und Ergänzungen' within the same entry 'Austern'-->
    <xsl:template match="article[descendant::lem eq 'Austern']">
        <xsl:variable name="lemma" select="translate(.//lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="lem" select='translate($lemma, $apos, "")'/>
        <entry xml:id="{concat(generate-id(.), $crtUri)}" xml:lang="de">
            <form type="lemma">
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <def><xsl:for-each select=".//p[not(preceding-sibling::h4)]">
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </xsl:for-each>
                <note>
                    <note type="footnote" xml:id="{concat($lem,'.')}">
                        <xsl:for-each select=".//p[preceding-sibling::h4]">
                            <xsl:apply-templates/>
                        </xsl:for-each>
                    </note>
                </note></def>
            </sense>
        </entry>
    </xsl:template>

</xsl:stylesheet>
