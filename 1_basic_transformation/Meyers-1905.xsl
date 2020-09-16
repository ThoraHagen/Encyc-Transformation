<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
            xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Meyers-1905-000.xml')"/> 
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:variable name="back" select="document('Meyers-1905-002-Anhang.xml')"/> 
    
    <!-- Appendix -->
    <!-- weitere Tags in figures untersuchen -->

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
                                <figure>
                                    <xsl:variable name="cover" select="./parent::DEFBOOK/BOOKTITLEFACS"/>
                                    <graphic url="{$cover}"/>
                                </figure>
                            </xsl:for-each>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <front>
                    <div type="mainpage">
                        <div type="title">
                            <xsl:for-each select="$file/doc//div[@class = 'zenoCOTitles']/*">
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
                    <div type="preface">
                        <xsl:for-each select="$file//articlegroup[@name = 'M']/article/article">
                            <div>
                                <head>
                                    <xsl:value-of select=".//h2"/>
                                </head>
                                <xsl:for-each select=".//p">
                                    <p>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </xsl:for-each>
                       
                    </div>
                </front>
                <body>
                    <div>
                        <xsl:apply-templates/>
                    </div>
                </body>
                <back>
                    <div>
                        <xsl:apply-templates select="$back/node()"/>
                    </div>
                </back>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="link">
        <xsl:variable name="lemma" select="@lem"/>
        <ref type="entry" target="{$lemma}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
    
    <xsl:template match="lemsupfloat[@link]">
        <xsl:variable name="lemma" select="@link"/>
        <term>
        <ref type="entry" target="{$lemma}">
            <xsl:apply-templates/>
        </ref>
        </term>
    </xsl:template>

    <!-- ________________________footnote handling________________________  -->
    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type='footnote' target="{concat($lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type='footnote'>
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>
    

    <xsl:template match="pname"/>
    
    <!-- counter nested <def> tags -->
    <xsl:template match='p' priority='2'>
        <xsl:apply-templates/>
    </xsl:template> 
    
    <xsl:template match="text">
        <def>
            <xsl:apply-templates/>
        </def>
    </xsl:template>
    
    <!-- appendix -->
    
    <xsl:template match="$back//article" >
        <entry xml:id="{concat(generate-id(.), $crtUri, '-app')}" xml:lang="de">
            <form>
                <term><xsl:value-of select=".//lem"/></term>
            </form>
            <sense xml:id='{generate-id(.)}'><xsl:apply-templates/></sense>
        </entry>
    </xsl:template>
    
    <xsl:template match='$back//text' priority='2'>
        <xsl:apply-templates/>
    </xsl:template> 
    
    <xsl:template match="$back//p" priority='3'>
        <def>
            <xsl:apply-templates/>
        </def>
    </xsl:template>
        

    <!-- _____________________ Meyers specific - missing <p> tags (code by K. Betz) _____________________-->

    <xsl:template match="text[child::*[1][self::b]][text()]"  priority='2'>
        <def>
            <xsl:apply-templates select="preceding-sibling::restructurePages/*"/>
            <xsl:apply-templates select="b[1]" mode="floatingLemma"/>

            <xsl:for-each-group select="node()"
                group-ending-with="p[preceding-sibling::text()[matches(., '\S')]][not(preceding-sibling::p)]">
                <xsl:choose>
                    <xsl:when
                        test="self::text()[matches(., '^\s+$')] and (following-sibling::node()[1])[self::b]">
                        <xsl:apply-templates mode="restructure" select="current-group()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- folgende <p> im gleichen Artikel werden normal transformiert -->
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </def>
    </xsl:template>

    <!-- in umstrukturierten Artikeln die fehlerhaften Zeno-<p> entfernen -->
    <xsl:template match="p" mode="restructure">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="text()" mode="#all">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- Umsetzung mit <hi> unterdrücken, es ist in diesem Fall das floating lemma -->
    <xsl:template match="b" mode="restructure"/>

    <!-- b als floating lemma umsetzen -->
    <xsl:template match="b" mode="floatingLemma">
        <term><hi rend='bold'>
            <xsl:apply-templates select="@* | node()"/></hi>
        </term>
    </xsl:template>

    <xsl:template match="h4" priority="2">
        <note type="header">
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <term><hi rend='bold'>
            <xsl:apply-templates/></hi>
        </term>
    </xsl:template>
    
</xsl:stylesheet>
