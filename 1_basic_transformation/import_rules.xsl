<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:variable name="crtUri" select="tokenize(document-uri(/), '/')[last()]"/>

    <!-- Base script for TEI transformation. -->



    <!-- ____________________ Identity Transformation for development ____________________ -->

    <!-- <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|comment()|processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>-->

    <!-- _______________________________________________________________ -->
    <!-- ____________________ Basic Entry Structure ____________________ -->

    <xsl:template match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]/article">
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

    <xsl:template match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]">
        <div type="{@name}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]//text/p"
        priority="2">
        <def>
            <xsl:apply-templates/>
        </def>
    </xsl:template>

    <!-- ____________________ Footnotes ____________________ -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma" select="./ancestor::article/lem/text()"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat('#', $lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fn">
        <note>
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma" select="./ancestor::article/lem/text()"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <!-- ____________________ Images ____________________ -->

    <xsl:template match="image">
        <figure xml:id="{concat(generate-id(), '-f')}">
            <graphic url="{@src}"/>
            <xsl:if test="./imagetext">
                <head>
                    <xsl:value-of select="./imagetext"/>
                </head>
            </xsl:if>
            <xsl:if test="./imagefindtext">
                <figDesc>
                    <xsl:value-of select="./imagefindtext"/>
                </figDesc>
            </xsl:if>
        </figure>
    </xsl:template>

    <xsl:template match="imagetext"/>

    <!-- ____________________ Links to other entries ____________________ -->

    <xsl:template match="link">
        <xsl:variable name="lemma" select="@lem"/>
        <!-- Lemma in 'target' can lead to validation errors in the result document -->
        <!-- will be handeled with the lemma to entry-ID transformation -->
        <ref type="entry" target="{$lemma}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>


    <!-- ____________________ unwanted tags ____________________ -->
    <xsl:template match="META | sigel | startpage | page | lem"/>
    <xsl:template match="articlegroup[@name = 'M'] | articlegroup[@name = '-']"/>
    <xsl:template match="p[@class = 'zenoPLm8n8']" priority="1"/>
    <xsl:template match="articlegroup[@name = 'M' or @name = '-']//ul" priority="1"/>
    <xsl:template match="article/cat[@name = 'Literaturverzeichnis']"/>


    <!-- ____________________ Inline tags/typography ____________________ -->

    <xsl:template match="i">
        <hi rend="italic">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="u">
        <hi rend="underline">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="sup">
        <hi rend="superscript">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="spa">
        <hi rend="spaced">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="sub">
        <hi rend="subscript">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="b | tt">
        <hi rend="bold">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="br"/>

    <xsl:template match="i" mode="lemfloat">
        <hi>
            <xsl:apply-templates/>
        </hi>
    </xsl:template>

    <xsl:template match="lemfloat | lemsupfloat">
        <term>
            <xsl:apply-templates/>
        </term>
    </xsl:template>

    <xsl:template match="h3">
        <note type="header">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="article//h4">
        <note type="header">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <!-- ____________________ Special tags ____________________ -->

    <!-- Lists -->

    <xsl:template match="article//ol | article//ul" priority="2">
        <xsl:choose>
            <xsl:when test=".[not(ancestor::ul) and not(ancestor::ol)]">
                <def>
                    <list>
                        <xsl:apply-templates/>
                    </list>
                </def>
            </xsl:when>
            <xsl:otherwise>
                <list>
                    <xsl:apply-templates/>
                </list>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="li">
        <item>
            <xsl:apply-templates/>
        </item>
    </xsl:template>

    <!-- Verse -->

    <xsl:template match="article//verse">
        <def>
            <lg>
                <xsl:for-each select="./p">
                    <l>
                        <xsl:apply-templates/>
                    </l>
                </xsl:for-each>
            </lg>
        </def>
    </xsl:template>

    <!-- Tables -->

    <xsl:template match="table">
        <def>
            <table>
                <xsl:apply-templates/>
            </table>
        </def>
    </xsl:template>

    <xsl:template match="tr">
        <row>
            <xsl:apply-templates/>
        </row>
    </xsl:template>

    <xsl:template match="td">
        <cell>
            <xsl:apply-templates/>
            <!-- Footnotes in Tables -->
            <!-- Pull fnrefs from table rows into corresponding cells -->
            <xsl:if test="./following-sibling::*[1]/name() eq 'fnref'">
                <xsl:variable name="lemma"
                    select="translate(./ancestor::article[not(descendant::sigel)]/lem/text(), ' :-(),', '')"/>
                <xsl:variable name="fnnumber" select="./following-sibling::*[1]/@id"/>
                <ref type="footnote" target="{concat('#',$lemma, $fnnumber)}"/>
            </xsl:if>
        </cell>
    </xsl:template>

    <xsl:template match="table//fnref" priority="2"/>

    <xsl:template match="fn//table" priority="2">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <!-- Other -->

    <xsl:template match="gr">
        <foreign xml:lang="el">
            <xsl:apply-templates/>
        </foreign>
    </xsl:template>
</xsl:stylesheet>
