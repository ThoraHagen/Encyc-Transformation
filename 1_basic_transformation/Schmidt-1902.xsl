<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:import href="preface.xsl"/>

    <!-- mehrere lgs sind durch def getrennt -->
    <!-- mehrere verse zusammennehmen ? -->


    <!-- ________________________Basic TEI Structure________________________ -->

    <xsl:template match="/">
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:value-of select="//META/DEFSERVER/TITLE"/>
                        </title>
                        <author>
                            <xsl:value-of select="/doc//div[@class = 'zenoCOTitles']/h3[1]"/>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <publisher/>
                        <date>
                            <xsl:value-of select="/doc/META/DEFSERVER/YEARS"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <xsl:for-each select="/doc/META/DEFBOOK/BOOKCITE">
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
                                    select=".//articlegroup[@name = '-']//image/@src"/>
                                <graphic url="{$cover}"/>
                            </figure>
                            <xsl:for-each
                                select="//articlegroup[@name = '-']//h1 | //articlegroup[@name = '-']//h2 | //articlegroup[@name = '-']//h3">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select="//articlegroup[@name = '-']//text//p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div type="preface">
                        <xsl:for-each select="//articlegroup[@name = 'M']/article">
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


    <!-- ________________________corrections: p-s and i-s were mixed on the same level________________________ -->
    <xsl:template match="text[p and (i or text()[matches(., '\w')])]">

        <xsl:for-each-group select="node()"
            group-starting-with="p | text() | element()[not(self::p)]">
            <xsl:choose>

                <xsl:when test="self::p">
                    <xsl:apply-templates select="current-group()"/>
                </xsl:when>

                <xsl:when test="self::text()[matches(., '\w')] | self::element()[not(self::p)]">
                    <def>
                        <xsl:apply-templates select="current-group()"/>
                    </def>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:apply-templates select="current-group()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match='p[@class = "zenoCOLit"]'>
        <def>
            <bibl>
                <xsl:apply-templates/>
            </bibl>
        </def>
    </xsl:template>

    <!-- ________________________exceptions________________________ -->
    <xsl:template
        match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]/article[child::lem eq 'Meyer, Familie (Detmold, Lemgo)']"
        priority="2">
        <entry xml:id="{concat(generate-id(.), 'detmold', $crtUri)}" xml:lang="de">

            <form>
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>

            <sense xml:id="{generate-id(.)}">
                <xsl:apply-templates/>
                <xsl:for-each select="//fn">
                    <note>
                        <xsl:apply-templates/>
                    </note>
                </xsl:for-each>
            </sense>
        </entry>
    </xsl:template>

    <xsl:template match="fnref">
        <xsl:variable name="lemma" select="translate(./ancestor::article/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <ref type="footnote" target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(//lem[. eq 'Meyer, Familie (Detmold, Lemgo)']/text(), ' :-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>

    <xsl:template match="fn"/>

    <!-- ________________________first <b> is the headword________________________ -->
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <term type="headword">
            <hi rend="bold">
                <xsl:apply-templates/>
            </hi>
        </term>
    </xsl:template>


</xsl:stylesheet>
