<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Goetzinger-1885-000.xml')"> </xsl:variable>
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
                            <figure>
                                <xsl:variable name="cover" select="$file//articlegroup[@name = '-']//image/@src"/>
                                <graphic url="{$cover}"/>
                            </figure>
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
                    <xsl:apply-templates select="$file//articlegroup[@name = 'M']/article" mode="preface"/>
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
    
    <!-- ________________________preface________________________ -->
    
    <xsl:template match="$file//articlegroup[@name = 'M']/article" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>
    
    <xsl:template match="article/text" mode="preface">
        
        <xsl:apply-templates mode="preface"/>
        
    </xsl:template>

    <!-- ________________________footnote handling________________________ -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type='footnote' target="{concat($lemma,'.', $fnnumber)}"/>
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

    <!-- ________________________verse grouping with adjacent p (zenoPLm4n8) Tags________________________-->

    <!-- not all verses are marked with <verse>, here they are instead marked with classes of <p>
            - most adjacent <p>s with class value "zenoPLm4n8" or "zenoPLm8n12" are verse
            - exceptions were identified manually and included here
    -->

    <xsl:key name="kFollowing" match="p[preceding-sibling::*[1][self::p] and
        (@class = 'zenoPLm4n8' or (@class = 'zenoPLm8n12' and (
    not(contains(.//text(), 'Gottfried von'))
    and not(contains(.//text(), 'Hesse von'))
    and not(contains(.//text(), 'Freidank'))
    and not(contains(.//text(), 'Ayrer.'))
    and not(contains(.//text(), 'Lampr. Alex.'))
    and not(contains(.//text(), 'R. Sp..'))
    and not(contains(.//text(), 'Parz.')))))]"
        use="
            generate-id(preceding-sibling::p
            [not(preceding-sibling::*[1][self::p]) and (@class = 'zenoPLm4n8' or (@class = 'zenoPLm8n12' and (
        not(contains(.//text(), 'Gottfried von'))
        and not(contains(.//text(), 'Hesse von'))
        and not(contains(.//text(), 'Freidank'))
        and not(contains(.//text(), 'Ayrer.'))
        and not(contains(.//text(), 'Lampr. Alex.'))
        and not(contains(.//text(), 'R. Sp..'))
        and not(contains(.//text(), 'Parz.')))))][1])"/>
    <xsl:template
        match="
            p
            [not(preceding-sibling::*[1][self::p[(@class = 'zenoPLm4n8' or (@class = 'zenoPLm8n12' and (
           not(contains(.//text(), 'Gottfried von'))
            and not(contains(.//text(), 'Hesse von'))
            and not(contains(.//text(), 'Freidank'))
            and not(contains(.//text(), 'Ayrer.'))
            and not(contains(.//text(), 'Lampr. Alex.'))
            and not(contains(.//text(), 'R. Sp..'))
            and not(contains(.//text(), 'Parz.')))))]]) and (@class = 'zenoPLm4n8' or (@class = 'zenoPLm8n12' and (
            not(contains(.//text(), 'Gottfried von'))
            and not(contains(.//text(), 'Hesse von'))
            and not(contains(.//text(), 'Freidank'))
            and not(contains(.//text(), 'Ayrer.'))
            and not(contains(.//text(), 'Lampr. Alex.'))
            and not(contains(.//text(), 'R. Sp..'))
            and not(contains(.//text(), 'Parz.')))))]">
        <def>
            <lg>
                <xsl:call-template name="p"/>
                <xsl:apply-templates mode="copy" select="key('kFollowing', generate-id())"/>
            </lg>
        </def>
    </xsl:template>

    <xsl:template
        match="p[preceding-sibling::*[1][self::p[(@class = 'zenoPLm4n8' or (@class = 'zenoPLm8n12' and (
        not(contains(.//text(), 'Gottfried von'))
        and not(contains(.//text(), 'Hesse von'))
        and not(contains(.//text(), 'Freidank'))
        and not(contains(.//text(), 'Ayrer.'))
        and not(contains(.//text(), 'Lampr. Alex.'))
        and not(contains(.//text(), 'R. Sp..'))
        and not(contains(.//text(), 'Parz.')))))]] and (@class = 'zenoPLm4n8' or (@class = 'zenoPLm8n12' and (
         not(contains(.//text(), 'Gottfried von'))
         and not(contains(.//text(), 'Hesse von'))
         and not(contains(.//text(), 'Freidank'))
         and not(contains(.//text(), 'Ayrer.'))
         and not(contains(.//text(), 'Lampr. Alex.'))
         and not(contains(.//text(), 'R. Sp..'))
         and not(contains(.//text(), 'Parz.')))))]"/>

    <xsl:template match="p" mode="copy">
        <xsl:call-template name="p"/>
    </xsl:template>

    <xsl:template match="p" mode="copy" name="p">
        <l>
            <xsl:apply-templates/>
        </l>
    </xsl:template>
    
    <xsl:template match="p[@class = 'zenoPLm8n12' and (contains(.//text(), 'A. H.')
        or contains(.//text(), 'Gottfried von')
        or contains(.//text(), 'Hesse von')
        or contains(.//text(), 'Freidank')
        or contains(.//text(), 'Ayrer.')
        or contains(.//text(), 'Lampr. Alex.')
        or contains(.//text(), 'R. Sp..')
        or contains(.//text(), 'Parz.'))]" priority="5">
        <def>
            <xsl:apply-templates/>
        </def>
    </xsl:template>

</xsl:stylesheet>
