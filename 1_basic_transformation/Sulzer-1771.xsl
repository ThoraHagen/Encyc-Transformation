<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Sulzer-1771-000.xml')"/> 
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
                        <xsl:for-each select="$file//articlegroup[@name = '-']//text//p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div type="preface">
                        <xsl:for-each select="$file//articlegroup[@name = 'M']/article">
                            <xsl:apply-templates mode="preface"/>
                        </xsl:for-each>
                    </div>
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

    <xsl:template match="plink">
        <xsl:variable name="lemma" select="replace(./@href, '/.*/', '')"/>
        <ref type="entry" target="{$lemma}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <!-- ________________________first <b> can be the headword________________________ -->
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <xsl:variable name="term" select="./ancestor::article/lem/text()"/>
        <xsl:variable name="b" select="translate(., '*,.', '')"/>
        <xsl:choose>
            <xsl:when test="contains($term, $b)">
                <term type="headword">
                    <hi rend="bold">
                        <xsl:apply-templates/>
                    </hi>
                </term>
            </xsl:when>
            <xsl:otherwise>
                <hi rend="bold">
                    <xsl:apply-templates/>
                </hi>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ________________________preface handling________________________  -->
    <xsl:template match="article[descendant::h3]" mode="preface">
        <div>
            <xsl:for-each-group group-starting-with="h3" select="text/*">
                <div>
                    <head>
                        <xsl:value-of select="current-group()[self::h3]"/>
                        <xsl:value-of select="current-group()[self::h2]"/>
                    </head>
                    <xsl:for-each select="current-group()[self::p]">
                        <p>
                            <xsl:apply-templates/>
                        </p>
                    </xsl:for-each>
                </div>
            </xsl:for-each-group>
        </div>
    </xsl:template>

    <!-- ________________________verse grouping with adjacent p (zenoPLm4n4) Tags________________________-->

    <xsl:template
        match="br[(count(preceding-sibling::br) = 0) or not(count(preceding-sibling::br) mod 2 = 1)]">
        <xsl:variable name="pos" select="count(./preceding-sibling::br) + 1"/>
        <def>
            <lg>
                <xsl:for-each select="./following-sibling::p[count(preceding-sibling::br) = $pos]">
                    <l>
                        <xsl:apply-templates/>
                    </l>
                </xsl:for-each>
            </lg>
        </def>
    </xsl:template>
    
    <xsl:template match="p[
        preceding-sibling::br[1][(count(preceding-sibling::br) = 0) or not(count(preceding-sibling::br) mod 2 = 1)]]"/>

    <!-- ________________________Footnote handling________________________  -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <ref type="footnote" target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>


</xsl:stylesheet>
