<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:import href="preface.xsl"/>
    <xsl:variable name="crtUri" select="tokenize(document-uri(/), '/')[last()]"/>

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
                            <xsl:value-of select="doc//div[@class = 'zenoCOTitles']/h3[1]"/>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <publisher/>
                        <date>
                            <xsl:value-of select="doc/META/DEFSERVER/YEARS"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <xsl:for-each select="doc/META/DEFBOOK/BOOKCITE">
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
                            <xsl:for-each select="doc//div[@class = 'zenoCOTitles']/*">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select="//articlegroup[@name = '-']//text/p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div type="preface">
                        <div>
                            <head>
                                <xsl:value-of
                                    select="//articlegroup[@name = 'M']/article[child::cat[@name = 'Einleitung']]//h2[1]"
                                />
                            </head>
                            <div>
                                <xsl:for-each
                                    select="//articlegroup[@name = 'M']/article[child::cat[@name = 'Einleitung']]//text//p">
                                    <p>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </div>
                        <xsl:apply-templates select="//article[./lem[. eq 'Stahlstiche']]"
                            mode="preface"/>
                    </div>
                </front>
                <body>
                    <div>
                        <xsl:apply-templates/>
                    </div>
                </body>
                <back/>
            </text>
        </TEI>
    </xsl:template>

    <!-- ________________________footnote handling________________________ -->

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
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>

    <!-- ________________________Basic Entry Structure________________________ -->

    <!-- special for DamenConvLex, as the article hierarchy is different here -->

    <xsl:template match="articlegroup[child::catdiv[@name = 'Lexikalischer Artikel']]//article">
        <entry xml:id="{concat(generate-id(.), $crtUri)}" xml:lang="de">
            <form>
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <xsl:apply-templates/>
            </sense>
        </entry>
    </xsl:template>

    <xsl:template match="articlegroup[child::catdiv[@name = 'Lexikalischer Artikel']]">
        <div type="{@name}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="articlegroup[child::catdiv[@name = 'Lexikalischer Artikel']]//text/p"
        priority="2">
        <def>
            <xsl:apply-templates/>
        </def>
    </xsl:template>

    <xsl:template match="p[@class = 'zenoPSSig']" priority="3">
        <def>
            <bibl>
                <author>
                    <xsl:apply-templates/>
                </author>
            </bibl>
        </def>
    </xsl:template>

    <!-- ________________________more references through <spa>________________________ -->
    <xsl:template
        match="article/text//spa[contains(substring(following-sibling::text()[1], 1, 8), ' (s. d.')]">
        <xsl:variable name="lemma" select=".//text()"/>
        <ref type="entry" target="{$lemma}">
            <hi rend="spaced">
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>

</xsl:stylesheet>
