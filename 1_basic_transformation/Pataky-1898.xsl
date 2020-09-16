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
                            <xsl:value-of select="//META/DEFSERVER/TITLE"/>
                        </title>
                        <author>
                            <xsl:value-of select="/doc//div[@class = 'zenoCOTitles']/h3[1]"/>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <publisher/>
                        <date>
                            <xsl:value-of select="/doc/META/DEFSERVER/YEARS"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <xsl:for-each select="/doc/META/DEFBOOK/BOOKCITE">
                                <title>
                                    <xsl:apply-templates/>
                                </title>

                            </xsl:for-each>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <front>
                    <div type="mainpage">
                        <div type="title">

                            <xsl:for-each
                                select="//articlegroup[@name = '-']//h1 | //articlegroup[@name = '-']//h2 | //articlegroup[@name = '-']//h3">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select="//articlegroup[@name = '-']//text//p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div type="preface">
                        <xsl:for-each select="//articlegroup[@name = 'M']/article/article">
                            <div>
                                <head>
                                    <xsl:value-of select=".//h2"/>
                                </head>
                                <xsl:for-each select=".//p[not(ancestor::fn)] | .//ul">
                                    <xsl:if test="./name() = 'p'">
                                        <p>
                                            <xsl:apply-templates/>
                                        </p>
                                    </xsl:if>
                                    <xsl:if test="./name() = 'ul'">
                                        <list>
                                            <xsl:apply-templates/>
                                        </list>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:if test="./lem/text() eq 'Vorwort'">
                                    <xsl:for-each select="//articlegroup[@name = 'M']//text/fn">
                                        <p>
                                            <xsl:apply-templates/>
                                        </p>
                                    </xsl:for-each>
                                </xsl:if>
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

    <xsl:template match="fnref">
        <xsl:variable name="lemma" select="./ancestor::article[1]/lem/text()"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat('#', $lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma" select="./ancestor::article[1]/lem/text()"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <!-- ________________________first <b> might be the headword________________________ -->
    <xsl:template match="articlegroup[@name = 'A']/article/text/p[1]/b[not(preceding-sibling::*)]">
        <xsl:variable name="term" select="./ancestor::article/lem/text()"/>
        <xsl:variable name="b" select="translate(., '*,', '')"/>
        <xsl:variable name="b" select="translate($b, '&#x25A1;', '')"/>
        <xsl:choose>
            <xsl:when test="contains($term, $b)">
                <term type="headword">
                    <hi rend="bold">
                        <xsl:apply-templates/>
                    </hi>
                </term>
            </xsl:when>
            <xsl:otherwise>
                <hi rend="bold">
                    <xsl:apply-templates/>
                </hi>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- implied references through <spa>-->

    <xsl:template match='catdiv[@name = "Lexikalischer Artikel"]//spa'>
        <xsl:variable name="string"
            select="replace(./text()[last()], 'Biographie| s\.|siehe|Werke| u\.|:|Ergänzg\.|Ergänzung|Band|weitere|allen|Inhalt|beiden|Weitere|unter|\)|\(', '')"/>
        <xsl:variable name="string" select="replace($string, '^ ?und|^ ?auch|^ \.', '')"/>
        <xsl:variable name="string" select="normalize-space($string)"/>
        <!-- .* ?\w{2}(\. ).+ -->
        <xsl:variable name="substrings"
            select="tokenize($string, '( und )|( auch )|(^und )|(^auch )')"/>

        <xsl:choose>
            <xsl:when test="$string = '' or $string = 'Nachtrag'">
                <xsl:apply-templates/>
            </xsl:when>

            <xsl:when test="count($substrings) = 2">

                <xsl:choose>
                    <xsl:when
                        test="$substrings[1] = '' or $substrings[1] = 's' or $substrings[1] = 'und' or $substrings[1] = 'Nachtrag'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="substring" select="normalize-space($substrings[1])"/>
                        <xsl:variable name="substring" select="replace($substring, '^\. |^, ', '')"/>
                        <xsl:variable name="substring"
                            select="replace($substring, '(.+) (\w+-?\w+$)', '$2, $1')"/>
                        <ref type="entry" target="{$substring}"/>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:choose>
                    <xsl:when
                        test="$substrings[2] = '' or $substrings[2] = 's' or $substrings[2] = 'und' or $substrings[2] = 'Nachtrag'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="substring" select="normalize-space($substrings[2])"/>
                        <xsl:variable name="substring" select="replace($substring, '\.$|,$', '')"/>
                        <xsl:variable name="substring"
                            select="replace($substring, '(.+) (\w+-?\w+$)', '$2, $1')"/>
                        <ref type="entry" target="{$substring}">
                            <hi rend="spaced">
                                <xsl:apply-templates/>
                            </hi>
                        </ref>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="count($substrings) = 3">

                <xsl:choose>
                    <xsl:when
                        test="$substrings[1] = '' or $substrings[1] = 's' or $substrings[1] = 'und' or $substrings[1] = 'Nachtrag'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="substring" select="normalize-space($substrings[1])"/>
                        <xsl:variable name="substring" select="replace($substring, '^\. |^, ', '')"/>
                        <xsl:variable name="substring"
                            select="replace($substring, '(.+) (\w+-?\w+$)', '$2, $1')"/>
                        <ref type="entry" target="{$substring}"/>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:choose>
                    <xsl:when
                        test="$substrings[2] = '' or $substrings[2] = 's' or $substrings[2] = 'und' or $substrings[2] = 'Nachtrag'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="substring" select="normalize-space($substrings[2])"/>
                        <xsl:variable name="substring"
                            select="replace($substring, '(.+) (\w+-?\w+$)', '$2, $1')"/>
                        <ref type="entry" target="{$substring}"/>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:choose>
                    <xsl:when
                        test="$substrings[3] = '' or $substrings[3] = 's' or $substrings[3] = 'und' or $substrings[3] = 'Nachtrag'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="substring" select="normalize-space($substrings[3])"/>
                        <xsl:variable name="substring" select="replace($substring, '\.$|,$', '')"/>
                        <xsl:variable name="substring"
                            select="replace($substring, '(.+) (\w+-?\w+$)', '$2, $1')"/>
                        <ref type="entry" target="{$substring}">
                            <hi rend="spaced">
                                <xsl:apply-templates/>
                            </hi>
                        </ref>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="$substrings[1] = '' or $substrings[1] = 's' or $substrings[1] = 'à' or $substrings[1] = 'Nachtrag'">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="substring"
                            select="replace($substrings[1], '(.+) (\w+-?\w+$)', '$2, $1')"/>
                        <xsl:variable name="substring" select="replace($substring, ', ,|, \.', ',')"/>
                        <ref type="entry" target="{$substring}">
                            <hi rend="spaced">
                                <xsl:apply-templates/>
                            </hi>
                        </ref>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
