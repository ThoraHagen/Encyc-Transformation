<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>

    <!-- ________________________Basic TEI Structure________________________ -->

    <xsl:template match="/">
        <TEI>
            <teiHeader>

                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:value-of select="doc/META/DEFSERVER/TITLE"/>
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
                        <head>
                            <xsl:value-of select="//articlegroup[@name = 'M']//h2[1]"/>
                        </head>
                        <div>
                            <xsl:for-each select="//articlegroup[@name = 'M']//text[1]/p">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <div>
                            <xsl:for-each select="//articlegroup[@name = 'M']//text[1]/fn">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
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

    <xsl:template
        match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]//text/div[@class = 'zenoCOLit']/p"
        priority="3">
        <def>
            <bibl>
                <xsl:apply-templates/>
            </bibl>
        </def>
    </xsl:template>

</xsl:stylesheet>
