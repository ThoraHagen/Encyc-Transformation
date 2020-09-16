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
                            <xsl:value-of select=".//META/DEFSERVER/TITLE"/>
                        </title>
                        <author>
                            <xsl:value-of select=".//div[@class = 'zenoCOTitles']/h3[1]"/>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <publisher/>
                        <date>
                            <xsl:value-of select=".//doc/META/DEFSERVER/YEARS"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <xsl:for-each select=".//doc/META/DEFBOOK/BOOKCITE">
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
                    <div type='mainpage'>
                        <div type="title">
                            <figure>
                                <xsl:variable name="cover" select=".//articlegroup[@name = '-']//image/@src"/>
                                <graphic url="{$cover}"/>
                            </figure>
                            <xsl:for-each
                                select=".//articlegroup[@name = '-']//h1 | .//articlegroup[@name = '-']//h2 | .//articlegroup[@name = '-']//h3">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select=".//articlegroup[@name = '-']//text//p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <xsl:apply-templates select=".//articlegroup[@name = 'M']" mode="preface"/>
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
    
    <!-- ________________________special________________________ -->
    
    <xsl:template match="verse/p">
        <l>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <!-- ________________________preface________________________ -->
        
    <xsl:template match="articlegroup[@name = 'M']" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>
    
    <xsl:template match="text" mode="preface">
        <xsl:apply-templates mode="preface"/>
    </xsl:template>
    
    <xsl:template match="article[./lem eq 'Vorwort']" mode="preface">
        <head>Vorwort</head>
        <xsl:apply-templates mode="preface"/>
    </xsl:template>
    

    <!-- ________________________footnote handling________________________ -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="colon">»«</xsl:variable>
        <xsl:variable name="lem" select="translate($lemma, $colon, '')"/>
        
        <!-- correct IDs of 'Natur' -->
        <xsl:variable name="fnnumber">
        <xsl:choose>
            <xsl:when test="@id = '50'">
                <xsl:value-of select="2"/>
            </xsl:when>
            <xsl:when test="@id = '51'">
                <xsl:value-of select="3"/>
            </xsl:when>
            <xsl:when test="@id = '52'">
                <xsl:value-of select="4"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>
        
        <ref type='footnote' target="{concat('#',$lem,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="colon">»«</xsl:variable>
        <xsl:variable name="lem" select="translate($lemma, $colon, '')"/>
        
        <!-- correct ID again -->
        <xsl:variable name="fnnumber">
        <xsl:choose>
            <xsl:when test="@id = '52'">
                <xsl:value-of select="4"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>
        
        <note xml:id="{concat($lem,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>   
    
    <!-- ________________________verse exception________________________ -->

    <xsl:template match="article//fn//verse" priority="2">
            <lg>
                <xsl:for-each select="./p">
                    <l>
                        <xsl:apply-templates/>
                    </l>
                </xsl:for-each>
            </lg>
    </xsl:template>
    
    
    <!-- ________________________more references with <i>________________________ -->
    
    <xsl:template match="article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -8),  ' Art. ')
        or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -6),  ' S. ')
        or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -6),  ' s. ')
        or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -8),  ' Artikel'))]">
        <xsl:variable name="lemma" select="translate(.//text(), '.);','')"/>
        <ref type='entry' target= '{$lemma}'>
            <hi rend='italic'>
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>
    
</xsl:stylesheet>
