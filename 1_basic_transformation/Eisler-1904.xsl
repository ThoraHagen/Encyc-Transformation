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
                    <xsl:apply-templates select="//articlegroup[@name = 'M']" mode="preface"/>            
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
    
    <!-- ________________________preface handling________________________ -->
    <xsl:template match="articlegroup[@name = 'M']" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>
      
    <xsl:template match="article[lem[. eq 'Literaturverzeichnis']]/article" mode="preface">
        <xsl:for-each-group group-starting-with="//h2" select="text">
            <div>             
                <xsl:for-each select="current-group()[self::*]">             
                        <xsl:apply-templates mode='preface'/>                   
                </xsl:for-each>
            </div>
        </xsl:for-each-group>
    </xsl:template>
      
    <!-- ________________________handle lists in lists________________________ -->
    <xsl:template match="ol/ul | ul/ul" priority="3">
        <item>
            <list>
                <xsl:apply-templates/>
            </list>
        </item>
    </xsl:template>
    
    <!-- ________________________more references with <i>________________________ -->
    <xsl:template match="article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -4),  ' s. ')
        or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -4),  'S. ')
        or contains(substring(following-sibling::text()[1], 1,7),  's. d.'))]">
        <xsl:variable name="lemma" select=".//text()"/>
        <ref type='entry' target= '{$lemma}'>
            <hi rend='italic'>
            <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>

</xsl:stylesheet>
