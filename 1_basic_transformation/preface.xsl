<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <!-- Basic preface rules stylesheet -->

    <xsl:template match="verse" mode="preface">
        <p>
            <lg>
                <xsl:apply-templates mode="preface"/>
            </lg>
        </p>
    </xsl:template>

    <xsl:template match="gallery" mode="preface">
        <figure>
            <xsl:apply-templates/>
        </figure>
    </xsl:template>

    <xsl:template match="p" mode="preface">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="article" mode="preface">
        <div>
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>

    <xsl:template match="h1 | h2 | h3 | h4" mode="preface">
        <head>
            <xsl:apply-templates/>
        </head>
    </xsl:template>

    <xsl:template match="ul" mode="preface">
        <list>
            <xsl:apply-templates/>
        </list>
    </xsl:template>

    <xsl:template match="fnref" mode="preface">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::sigel]/lem/text(), ' :-(),', '')"/>
        <xsl:variable name="fnnumber" select="@id"/>
        <ref type="footnote" target="{concat('#', $lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fn" mode="preface">
        <div>
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>

    <xsl:template match="fntext" mode="preface">
        <p>
            <xsl:variable name="lemma"
                select="translate(./parent::fn/parent::text/parent::article/lem/text(), ' :-(),', '')"/>
            <xsl:variable name="fnnumber" select="@id"/>
            <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
                <xsl:apply-templates/>
            </note>
        </p>
    </xsl:template>

    <xsl:template match="lem" mode="preface"/>

    <xsl:template match="image" mode="preface">
        <figure>
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

</xsl:stylesheet>
