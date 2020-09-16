<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Brockhaus-1911-000.xml')"> </xsl:variable>
    <xsl:variable name="back" select="document('Brockhaus-1911-002-Anhang.xml')"> </xsl:variable>
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>


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
                                    <xsl:variable name="cover"
                                        select="./parent::DEFBOOK/BOOKTITLEFACS"/>
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
                            <figure>
                                <xsl:variable name="cover"
                                    select="$file//articlegroup[@name = '-']//image/@src"/>
                                <graphic url="{$cover}"/>
                            </figure>
                            <xsl:for-each
                                select="$file//articlegroup[@name = '-']//h1 | $file//articlegroup[@name = '-']//h2">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each
                            select="$file//articlegroup[@name = '-']//text//p | $file//articlegroup[@name = '-']//text//ul[not(.//b)]">
                            <div>
                                <xsl:if test="./name() = 'p'">
                                    <p>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:if>
                                <xsl:if test="./name() = 'ul'">
                                    <list>
                                        <xsl:apply-templates/>
                                    </list>
                                </xsl:if>
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
                    <xsl:apply-templates select="$back/doc"/>
                </back>
            </text>
        </TEI>
    </xsl:template>

    <!-- ________________________footnote handling (only applies to preface)________________________ -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat($lemma,'.', $fnnumber)}"/>
    </xsl:template>


    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>

    <!-- ________________________first <b> is the headword________________________ -->
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <term type="headword">
            <hi rend="bold">
                <xsl:apply-templates/>
            </hi>
        </term>
    </xsl:template>

    <!-- ________________________plinks to appendix________________________ -->

    <xsl:template match="article/text//plink[following-sibling::node()[1]/name() = 'i']">
        <xsl:variable name="text" select="./following-sibling::node()[1]/text()"/>
        <xsl:variable name="lemma" select="tokenize(./@href, '/')[last()]"/>
        <ref type="appendix" target="{$lemma}">
            <xsl:value-of select="$text"/>
        </ref>
    </xsl:template>

    <xsl:template match="article/text//i[preceding-sibling::node()[1]/name() = 'plink']"/>


    <!-- ________________________appendix________________________ -->

    <xsl:template match="$back//article[child::article]/lem | $back//article[child::article]/text"
        priority="2" mode="back"/>

    <xsl:template match="$back/doc">
        <xsl:apply-templates mode="back"/>
    </xsl:template>

    <xsl:template match="$back//article/article" mode="back">
        <entry xml:id="{concat(generate-id(.), $crtUri, '-app')}" xml:lang="de">
            <form>
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <xsl:apply-templates mode="back"/>
            </sense>
        </entry>
    </xsl:template>

    <xsl:template match="$back//article[child::article]" mode="back">
        <div type="{translate(lem/text(), ' ', '')}">
            <p>
                <xsl:value-of select="./text/h2"/>
            </p>
            <xsl:apply-templates mode="back"/>
        </div>
    </xsl:template>

    <xsl:template match="image" mode="back">
        <figure>
            <graphic url="{@src}"/>
            <xsl:if test="./imagetext">
                <head>
                    <xsl:value-of select="./imagetext"/>
                </head>
            </xsl:if>
            <xsl:if test="./imagefindtext">
                <figDesc>
                    <xsl:value-of select="./imagefindtext"/>
                </figDesc>
            </xsl:if>
        </figure>
    </xsl:template>

    <xsl:template match="lem" mode="back"/>

    <xsl:template match="p" mode="back">
        <def>
            <xsl:apply-templates mode="back"/>
        </def>
    </xsl:template>

    <xsl:template match="h2 | h3 | h4 | h5" mode="back">
        <note type="header">
            <xsl:apply-templates mode="back"/>
        </note>
    </xsl:template>

    <xsl:template match="i" mode="back">
        <hi rend="italic">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>

    <xsl:template match="article//ol | article//ul" priority="2" mode="back">
        <xsl:choose>
            <xsl:when test=".[not(ancestor::ul) and not(ancestor::ol)]">
                <def>
                    <list>
                        <xsl:apply-templates mode="back"/>
                    </list>
                </def>
            </xsl:when>
            <xsl:otherwise>
                <list>
                    <xsl:apply-templates mode="back"/>
                </list>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ol/ul | ul/ul" priority="3" mode="back">
        <item>
            <list>
                <xsl:apply-templates/>
            </list>
        </item>
    </xsl:template>

    <xsl:template match="li" mode="back">
        <item>
            <xsl:apply-templates mode="back"/>
        </item>
    </xsl:template>

    <xsl:template match="sub" mode="back">
        <hi rend="subscript">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>

    <xsl:template match="sup" mode="back">
        <hi rend="superscript">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>

    <xsl:template match="table" mode="back">
        <def>
            <table>
                <xsl:apply-templates mode="back"/>
            </table>
        </def>
    </xsl:template>

    <xsl:template match="tr" mode="back">
        <row>
            <xsl:apply-templates mode="back"/>
        </row>
    </xsl:template>

    <xsl:template match="td" mode="back">
        <cell>
            <xsl:apply-templates mode="back"/>
        </cell>
    </xsl:template>

    <!--    <xsl:template match="imagetext" mode="back">
        <note type="imagetext">
            <xsl:apply-templates mode="back"/>
        </note>
    </xsl:template>-->

</xsl:stylesheet>
