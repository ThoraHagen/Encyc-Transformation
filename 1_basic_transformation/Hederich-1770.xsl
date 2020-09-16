<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Hederich-1770-000.xml')"> </xsl:variable>
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
                    <xsl:apply-templates select="$file//articlegroup[@name = 'M']" mode="preface"/>
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


    <xsl:template match="span">
        <bibl>
            <xsl:apply-templates/>
        </bibl>
    </xsl:template>

    <!-- ________________________references________________________ -->
    <xsl:template
        match="
            article/text//b[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 'sieh '))] |
            article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 'sieh '))]">
        <xsl:variable name="lemma" select="normalize-space(.//text())"/>
        <ref type="entry" target="{$lemma}">
            <hi rend="spaced">
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>

    <!-- ________________________footnote handling________________________ -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::sigel]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat($lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::sigel]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <!-- ________________________preface handling________________________ -->

    <xsl:template match="$file//articlegroup[@name = 'M']" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>

    <xsl:template match="article[page[@nr = '14']]/lem" mode="preface">
        <head>
            <xsl:apply-templates/>
        </head>
    </xsl:template>

    <xsl:template match="text[child::h4]" mode="preface">
        <xsl:for-each-group group-starting-with="//h4" select="*">
            <div>
                <head>
                    <xsl:value-of select="current-group()[self::h4]"/>
                    <xsl:value-of select="current-group()[self::h3]"/>
                </head>
                <xsl:for-each select="current-group()[self::p]">
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </xsl:for-each>
            </div>
        </xsl:for-each-group>
    </xsl:template>

    <!-- ________________________give IDs to table images for referencing________________________ -->

    <xsl:template match="image[ancestor::article[contains(./lem, 'Genealogische Tabellen')]]"
        priority="2">
        <figure xml:id="{translate(./imagetext, ' ()', '')}">
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

    <!-- ________________________convert plinks to pointers to refer to table images________________________-->

    <xsl:template match="plink">
        <xsl:variable name="texttail" select="./following-sibling::text()[1]"/>

        <xsl:variable name="table" select="replace($texttail, '\).*', '')"/>
        <xsl:variable name="t" select="replace($table, '&amp;', '')"/>
        <xsl:variable name="t" select="replace($t, 'T.{0,2}\.', '')"/>
        <xsl:variable name="t" select="replace($t, ' ', '')"/>
        <xsl:variable name="t" select="replace($t, 'et', '')"/>

        <ref type="table" target="#Tab.{$t}"/>
    </xsl:template>

</xsl:stylesheet>
