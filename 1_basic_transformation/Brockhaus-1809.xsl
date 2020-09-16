<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Brockhaus-1809-000.xml')"> </xsl:variable>
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
                <back> </back>
            </text>
        </TEI>
    </xsl:template>

    <!-- ________________________preface handling________________________ -->

    <xsl:template match="$file//articlegroup[@name = 'M']" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>

    <xsl:template match="text[child::h5]" mode="preface">
        <xsl:for-each-group group-starting-with="//h5" select="*">
            <div>
                <head>
                    <xsl:value-of select="current-group()[self::h5]"/>
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

    <!-- ________________________footnote handling________________________ -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>


    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>


    <!-- ________________________Brockhaus 1809 footnotes________________________ -->

    <!-- h5 indicates footnotes
            - every <p> following <h5> is a footnote
            - references are marked by <plink>/<sup>
    -->

    <xsl:template match="//h5">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article//lem/text(), ' []:-();,', '')"/>
        <xsl:for-each select="./preceding-sibling::p">
            <def>
                <xsl:apply-templates/>
            </def>
        </xsl:for-each>
        <note>
            <xsl:for-each select="./following-sibling::p">
                <xsl:variable name="fnnumber" select="translate(plink[1]/text(), ' []:-();,', '')"/>
                <note type="footnote" xml:id="{concat($lemma,'.', $fnnumber)}">
                    <xsl:apply-templates/>
                </note>
            </xsl:for-each>
        </note>
    </xsl:template>

    <xsl:template match="sup[parent::plink]">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article//lem/text(), ' :-()[],', '')"/>
        <xsl:variable name="fnnumber" select="translate(./text(), ' []:-();,', '')"/>
        <ref type="footnote" target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="articlegroup/article[descendant::h5]//p" priority="5"/>


    <!-- ________________________footnote excpetion USA________________________ -->

    <!-- there are two entries with the same headword name (articlegroup A and B)
            - to link footnotes correctly, pointers to the second entry are marked with "B"
    -->
    <xsl:template
        match="//articlegroup[@name = 'B']//lem[. eq 'Die vereinigten Staaten von Nordamerika']//plink/sup"
        priority="2">
        <ref type="footnote" target="#DievereinigtenStaatenvonNordamerikaB.1"/>
    </xsl:template>

    <xsl:template
        match="//h5[ancestor::articlegroup[@name = 'B'] and ancestor::article[child::lem eq 'Die vereinigten Staaten von Nordamerika']]"
        priority="2">
        <xsl:for-each select="./preceding-sibling::p">
            <def>
                <xsl:apply-templates/>
            </def>
        </xsl:for-each>
        <note>
            <xsl:for-each select="./following-sibling::p">
                <note type="footnote" xml:id="DievereinigtenStaatenvonNordamerikaB.1">
                    <xsl:apply-templates/>
                </note>
            </xsl:for-each>
        </note>
    </xsl:template>

    <!-- ________________________footnote exception "not marked"________________________ -->

    <!-- some footnotes are not marked with <h5>
            - can only be identified through <plink> and its numbering
    -->

    <xsl:template
        match="p[child::plink[ancestor::article[not(descendant::h5)] and not(sup) and ancestor::p[not(@class)]] and not(contains(., '*'))]"
        priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article//lem/text(), ' []:-();,', '')"/>
        <note>
            <xsl:for-each select=".">
                <xsl:variable name="fnnumber" select="translate(plink[1]/text(), ' []:-();,', '')"/>
                <note type="footnote" xml:id="{concat($lemma,'.', $fnnumber)}">
                    <xsl:apply-templates/>
                </note>
            </xsl:for-each>
        </note>
    </xsl:template>

    <!-- ________________________Exception: Departements von Frankreich________________________ -->

    <!-- stars instead of numbers as a footnote identifier
            - count stars to build ID (as well as for <plink>)
    -->

    <xsl:template match="article[descendant::p[@class = 'zenoPC' and . eq 'Fußnoten']]">
        <entry xml:id="{concat(generate-id(.), $crtUri)}" xml:lang="de">
            <form type="lemma">
                <term>
                    <xsl:value-of select="./lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <xsl:variable name="lemma" select="translate(./lem/text(), ' []:-();,', '')"/>
                <xsl:for-each
                    select="./descendant::p[@class = 'zenoPC' and . eq 'Fußnoten']/preceding-sibling::p">
                    <def>
                        <xsl:apply-templates/>
                    </def>
                </xsl:for-each>
                <note>
                    <xsl:for-each
                        select="./descendant::p[@class = 'zenoPC' and . eq 'Fußnoten']/following-sibling::p">
                        <xsl:variable name="fnnumber" select="string-length(plink[1]/text())"/>
                        <note type="footnote" xml:id="{concat($lemma,'.', $fnnumber)}">
                            <xsl:apply-templates/>
                        </note>
                    </xsl:for-each>
                </note>
            </sense>
        </entry>
    </xsl:template>

    <xsl:template
        match="article[descendant::p[@class = 'zenoPC' and . eq 'Fußnoten']]//p[@class = 'zenoPLm4n0']//plink">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' :-()[],', '')"/>
        <xsl:variable name="fnnumber" select="string-length(./text())"/>
        <ref type="footnote" target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <!-- _______________________<plink>s containing keywords________________________ -->

    <!-- ... are references to other entries -->

    <xsl:template match="plink[contains(./text(), 'Note') or contains(./text(), 'Bemerkung')]">
        <xsl:variable name="lemma" select="replace(./@href, '/.*/', '')"/>
        <ref type="entry" target="{$lemma}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <!-- ________________________other references through <i>________________________ -->

    <xsl:template
        match="
            article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 8), 'Art. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 'S. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 's. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 8), 'Artikel'))]">
        <xsl:variable name="lemma" select=".//text()"/>
        <ref type="entry" target="{$lemma}">
            <hi rend="italic">
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>

    <!-- ________________________first <b> is the headword________________________ -->
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <term type="headword">
            <hi rend="bold">
                <xsl:apply-templates/>
            </hi>
        </term>
    </xsl:template>

</xsl:stylesheet>
