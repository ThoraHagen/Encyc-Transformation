<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
            xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
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
                                <xsl:variable name="cover" select=".//articlegroup[@name = '-']//image/@src"/>
                                <graphic url="{$cover}"/>
                            </figure>
                            <xsl:for-each select="doc//div[@class = 'zenoCOTitles']/*">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select=".//articlegroup[@name = '-']//text/p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div type="preface">
                        <xsl:for-each select=".//articlegroup[@name = 'M']/catdiv/article">
                            <xsl:apply-templates mode="preface"/>  
                        </xsl:for-each>                       
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
    
    <!-- ________________________missing <p>________________________ -->
    
    <xsl:template match="article[lem eq 'psychophysisches Gesetz']/text/text()[contains(., 'Konst')]">
        <def>
            <xsl:copy-of select="."/>
        </def>
    </xsl:template>
    
    <!-- ________________________floating 'R'________________________ -->
    
    <xsl:template match="articlegroup[@name='A']//h2"/>
    
    <!-- ________________________external references________________________ -->

    <xsl:template match="article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -10),  '. Vgl. ')
        or (preceding-sibling::i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -10),  '. Vgl. '))])
       )]">
        <ref type='external'>
            <hi rend='italic'>
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>
    
    <xsl:template match="article/text//i[contains(substring(following-sibling::text()[1], 1,9),  '(s. d.')]
        " priority='2'>
        <ref type='entry' target='{./text()}'>
            <hi rend='italic'>
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>
    
    <xsl:template match="tt[p]">
        <def>
            <list>
                <xsl:apply-templates/>
            </list>
        </def>
    </xsl:template>
    
    <xsl:template match="tt/p">
        <item>
            <xsl:apply-templates/>
        </item>
    </xsl:template>
    
</xsl:stylesheet>
