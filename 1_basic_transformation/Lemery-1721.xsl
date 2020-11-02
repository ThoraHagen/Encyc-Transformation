<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Lemery-1721-000.xml')"/> 
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
                                select="$file//articlegroup[@name = '-']//h1 | $file//articlegroup[@name = '-']//h2 | $file//articlegroup[@name = '-']//h4">
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
                        <xsl:for-each select="$file//articlegroup[@name = 'M']/article/article">
                            <div>
                                <head>
                                    <xsl:value-of select=".//h2"/>
                                </head>
                                <xsl:for-each select=".//p">
                                    <p>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:for-each>
                                <xsl:for-each select=".//ul">
                                    <list>
                                        <xsl:apply-templates/>
                                    </list>
                                </xsl:for-each>
                            </div>
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
</xsl:stylesheet>
