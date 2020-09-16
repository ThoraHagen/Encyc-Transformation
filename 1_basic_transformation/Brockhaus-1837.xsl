<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Brockhaus-1837-000.xml')"> </xsl:variable>
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
                    <xsl:apply-templates select="$file//articlegroup[@name = 'M']/article"
                        mode="preface"/>
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

    <!-- ________________________special preface handling________________________ -->
    <xsl:template match="$file//articlegroup[@name = 'M']/article" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>

    <xsl:template match="article/text" mode="preface">
        <xsl:apply-templates mode="preface"/>
    </xsl:template>

    <xsl:template match="article[lem[. eq 'Verzeichnisse der Landkarten']]/text[child::h2]"
        mode="preface" priority="2">
        <xsl:for-each-group group-starting-with="//h2" select="h2 | gallery">
            <div>
                <head>
                    <xsl:value-of select="current-group()[self::h2]"/>
                </head>
                <xsl:for-each select="current-group()[self::gallery]">
                    <figure>
                        <xsl:apply-templates/>
                    </figure>
                </xsl:for-each>
            </div>
        </xsl:for-each-group>
    </xsl:template>

    <!-- ________________________first <b> is the headword________________________ -->
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <term type="headword">
            <hi rend="bold">
                <xsl:apply-templates/>
            </hi>
        </term>
    </xsl:template>

    <!-- ________________________references________________________ -->
    <xsl:template
        match="
            article/text//spa[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 8), 'vgl. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), ' s. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 'Vgl. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 'S.') or contains(substring(following-sibling::text()[1], 1, 7), '(s.d.'))]">
        <xsl:variable name="lemma" select="normalize-space(.//text())"/>
        <ref type="entry" target="{$lemma}">
            <hi rend="spaced">
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>

    <!-- ________________________verse________________________ -->

    <xsl:key name="kFollowing" match="p[preceding-sibling::*[1][self::p] and child::span]"
        use="
            generate-id(preceding-sibling::p
            [not(preceding-sibling::*[1][self::p]) and child::span][1])"/>

    <xsl:template
        match="
            p
            [not(preceding-sibling::*[1][self::p[child::span]]) and child::span and
            (ancestor::article/lem/text() eq 'Alexandriner' or
            ancestor::article/lem/text() eq 'Assonanz' or
            ancestor::article/lem/text() eq 'Böttger' or
            ancestor::article/lem/text() eq 'Charwoche' or
            ancestor::article/lem/text() eq 'Christoph [1]' or
            ancestor::article/lem/text() eq 'Distichon' or
            ancestor::article/lem/text() eq 'Eier' or
            ancestor::article/lem/text() eq 'Eulenspiegel' or
            ancestor::article/lem/text() eq 'Francke' or
            ancestor::article/lem/text() eq 'Franklin' or
            contains(ancestor::article/lem/text(), 'Jeanne') or
            ancestor::article/lem/text() eq 'Nagelprobe' or
            ancestor::article/lem/text() eq 'Nibelungenlied' or
            ancestor::article/lem/text() eq 'Räthsel' or
            ancestor::article/lem/text() eq 'Schiller' or
            ancestor::article/lem/text() eq 'Shakspeare' or
            ancestor::article/lem/text() eq 'Stabat mater' or
            ancestor::article/lem/text() eq 'Ut, Re, Mi, Fa, Sol, La' or
            ancestor::article/lem/text() eq 'Wieland'
            )]">
        <def>
            <lg>
                <xsl:call-template name="p"/>
                <xsl:apply-templates mode="copy1" select="key('kFollowing', generate-id())"/>
            </lg>
        </def>
    </xsl:template>

    <xsl:template match="p[preceding-sibling::*[1][self::p[child::span]]]"/>

    <xsl:template match="p" mode="copy1">
        <xsl:call-template name="p"/>
    </xsl:template>

    <xsl:template match="p" mode="copy1" name="p">
        <l>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <!-- ________________________lists________________________ -->

    <xsl:key name="kFollowinglist"
        match="p[preceding-sibling::*[1][self::p[child::span]] and child::span]"
        use="
            generate-id(preceding-sibling::p
            [not(preceding-sibling::*[1][self::p[child::span]]) and child::span][1])"/>

    <xsl:template
        match="
            p
            [not(preceding-sibling::*[1][self::p[child::span]]) and child::span and not(@class = 'zenoPC') and
            (ancestor::article/lem/text() eq 'Berg' or
            ancestor::article/lem/text() eq 'Classensteuern' or
            ancestor::article/lem/text() eq 'Gall' or
            ancestor::article/lem/text() eq 'Kettenrechnung' or
            ancestor::article/lem/text() eq 'Mond'
            )]">
        <def>
            <list>
                <xsl:call-template name="list"/>
                <xsl:apply-templates mode="copy2" select="key('kFollowinglist', generate-id())"/>
            </list>
        </def>
    </xsl:template>

    <xsl:template match="p[preceding-sibling::*[1][self::p[child::span]]]"/>

    <xsl:template match="p" mode="copy2">
        <xsl:call-template name="list"/>
    </xsl:template>

    <xsl:template match="p" mode="copy2" name="list">
        <item>
            <xsl:apply-templates/>
        </item>
    </xsl:template>

</xsl:stylesheet>
