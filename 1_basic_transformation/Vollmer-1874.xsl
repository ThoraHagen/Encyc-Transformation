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
                            <xsl:for-each
                                select=".//articlegroup[@name = '-']//h2 | .//articlegroup[@name = '-']//h3 | .//articlegroup[@name = '-']//h4">
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
              <!--      <xsl:apply-templates select=".//articlegroup[@name = 'M']//article" mode="preface"/>-->
                    <div type="preface">
                        <head>
                            <xsl:value-of
                                select=".//catdiv[@name = 'Einleitung']/article/lem/text()"/>
                        </head>
                        <xsl:for-each select=".//articlegroup[@name = 'M']//article/article">
                            <div>
                                <head>
                                    <xsl:value-of select=".//h2"/>
                                </head>
                                <xsl:for-each select=".//p[not(parent::verse) and not(ancestor::fn)] | .//h3 | .//h4 |.//verse">
                                    <xsl:choose>
                                        <xsl:when test="./name() eq 'verse'">
                                            <lg>
                                                <xsl:apply-templates/>
                                            </lg>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <p>
                                                <xsl:apply-templates/>
                                            </p>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                  
                                </xsl:for-each>
                            </div>
                        </xsl:for-each>
                        <div>
                            <xsl:for-each select=".//articlegroup[@name = 'M']//text/fn">
                                    <xsl:apply-templates/>
                            </xsl:for-each>
                        </div>
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
    
    <xsl:template match="verse/p">
        <l>
            <xsl:apply-templates/>
        </l>
    </xsl:template>
    
    <xsl:template match="articlegroup[@name = 'M']//article" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>
    
    <xsl:template match="article/text" mode="preface">
        <xsl:apply-templates mode="preface"/>
    </xsl:template>
    
    <xsl:template match="hide">
        <span type='origin'>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ____________________ Basic Entry Structure ____________________ -->

    <xsl:template
        match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]//article">
        <entry xml:id="{concat(generate-id(.), $crtUri)}" xml:lang="de">
            <form type="lemma">
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <xsl:apply-templates/>
            </sense>
        </entry>
    </xsl:template>

    <!-- ____________________footnote handling____________________  -->
    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <ref type='footnote' target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]/lem/text(), ' :-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>


</xsl:stylesheet>
