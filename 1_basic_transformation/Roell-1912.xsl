<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="file" select="document('Roell-1912-000.xml')"> </xsl:variable>

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
                            <xsl:for-each select="$file/doc//div[@class = 'zenoCOTitles']/*">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select="$file//articlegroup[@name = '-']//text/p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                        <!--<xsl:apply-templates/>  -->
                    </div>
                    <div type="preface">
                        <head>Vorwort und Nachwort.</head>
                        <div type="preface">
                            <xsl:for-each select="$file//articlegroup[@name = 'M']/article">
                                <xsl:apply-templates mode="preface"/>
                            </xsl:for-each>
                        </div>
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

    <xsl:template match="p[@class = 'zenoPSSig']" priority="3">
        <def>
            <bibl>
                <author>
                    <xsl:apply-templates/>
                </author>
            </bibl>
        </def>
    </xsl:template>

    <!-- ________________________anchor handling________________________ -->
    <xsl:template match="a[@href]">
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate(@href, $apos, '')"/>
        <ref type="image" target="{translate($target, ' :-(),', '')}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <xsl:template match="a[@name]">
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate(@name, $apos, '')"/>
        <anchor xml:id="{translate($target, ' :-(),', '')}">
            <xsl:apply-templates/>
        </anchor>
    </xsl:template>


    <!-- ________________________more refences________________________ -->
    <xsl:template
        match="article/text//spa[contains(substring(following-sibling::text()[1], 1, 7), 's.d.')]">
        <xsl:variable name="lemma" select=".//text()"/>
        <hi rend="spaced">
            <ref type="entry" target="{$lemma}">
                <xsl:apply-templates/>
            </ref>
        </hi>
    </xsl:template>

    <!-- ________________________footnote handling________________________ -->
    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat('#', $lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <!-- ________________________exceptions________________________ -->

    <xsl:template match="ul/text()[normalize-space()]" priority="2"/>

    <xsl:template match="article[descendant::lem[. eq 'Bremsbrutto']]//fn">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <note>
            <note xml:id="{concat($lemma,'.1')}" type="footnote">
                <xsl:apply-templates/>
            </note>
        </note>
    </xsl:template>

    <xsl:template match="a[@name = '111.']" priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
        <ref type="footnote" target="{concat('#', $lemma,'.1')}"/>
    </xsl:template>

    <xsl:template match="a[@name = '111']" priority="2"/>

    <xsl:template match="image[@src = 'Ro04430a.jpg']">
        <figure xml:id="{generate-id()}">
            <graphic url="{@src}"/>
            <head>
                <xsl:value-of select="."/>
            </head>
        </figure>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>


    <!-- ________________________Roell specific table/p-tag handling________________________ -->

    <xsl:template match="p[preceding-sibling::tr]" priority="2">
        <row>
            <cell>
                <xsl:apply-templates select="@* | node()"/>
            </cell>
            <xsl:variable name="cells" select="preceding-sibling::tr[1]/td"/>
            <xsl:for-each select="$cells/*">
                <cell/>
            </xsl:for-each>
        </row>
    </xsl:template>

    <xsl:template match="p[following-sibling::tr]" priority="1">
        <row>
            <cell>
                <xsl:apply-templates select="@* | node()"/>
            </cell>
            <xsl:variable name="cells" select="following-sibling::tr[1]/td"/>
            <xsl:for-each select="$cells/*">
                <cell/>
            </xsl:for-each>
        </row>
    </xsl:template>

</xsl:stylesheet>
