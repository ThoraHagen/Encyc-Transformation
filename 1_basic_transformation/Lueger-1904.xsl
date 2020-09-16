<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn=" http://www.w3.org/2005/xpath-functions">

    <xsl:variable name="file" select="document('Lueger-1904-000.xml')"> </xsl:variable>
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:import href="preface.xsl"/>


    <!-- Note: The original XML file is not well formed (images have two "width" attributes).
            - "width" was removed entirely to produce well formed XML.
    -->


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
                                select="$file//articlegroup[@name = '-']//h1 | $file//articlegroup[@name = '-']//h2">
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
                    <xsl:apply-templates select="$file//articlegroup[@name = 'M']" mode="preface"/>
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

    <xsl:template match="p[@class = 'zenoPSSig']" priority="3">
        <def>
            <bibl>
                <author>
                    <xsl:apply-templates/>
                </author>
            </bibl>
        </def>
    </xsl:template>

    <!-- ________________________preface handling________________________  -->

    <xsl:template match="$file//articlegroup[@name = 'M']" mode="preface">
        <div type="preface">
            <xsl:apply-templates mode="preface"/>
        </div>
    </xsl:template>

    <xsl:template match="text" mode="preface">
        <xsl:apply-templates mode="preface"/>
    </xsl:template>

    <!--  ________________________other references  with <i>________________________ -->
    <xsl:template
        match="
            article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 8), 'vgl. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), ' s. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), ' Vgl. ')
            or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) - 6), 'S. ')
            or contains(substring(following-sibling::text()[1], 1, 7), 's.d.')) and not(child::link) and not(parent::link)]">
        <xsl:variable name="lemma" select=".//text()"/>
        <ref type="entry" target="{$lemma}">
            <hi rend="italic">
                <xsl:apply-templates/>
            </hi>
        </ref>
    </xsl:template>

    <!-- ________________________footnote handling________________________  -->

    <xsl:template match="fnref">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(child::sigel)]//lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <ref type="footnote" target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="fntext">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[child::text[child::fn]]//lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="fnnumber" select="@name"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <!-- ________________________anchor handling________________________  -->

    <xsl:template match="a[@href]">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate($lemma, $apos, '')"/>
        <xsl:variable name="fnnumber" select="replace(./@href, '^\d?\D+', '')"/>
        <xsl:variable name="fnnumber2">
            <xsl:analyze-string regex="^\d?\D+" select="$fnnumber">
                <xsl:matching-substring> </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="fnnumber2" select="replace($fnnumber2, ' |,|\.', '')"/>
        <ref type="image"
            target="{concat('#', translate($target, ' :-(),', ''), '.', $fnnumber2, '_A')}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>


    <xsl:template match="a[@name]">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate($lemma, $apos, '')"/>
        <xsl:variable name="fnnumber" select="replace(./@name, '^\d?\D+', '')"/>
        <xsl:variable name="fnnumber" select="replace($fnnumber, ' ', '')"/>
        <xsl:variable name="fnnumber" select="replace($fnnumber, '\.|,', '')"/>
        <!-- <xsl:variable name="fnnumber" select="translate(./@name, translate(./@name,'0123456789',''), '')"/>-->
        <xsl:variable name="char">
            <xsl:choose>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'a')">
                    <xsl:value-of select="'a'"/>
                </xsl:when>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'b')">
                    <xsl:value-of select="'b'"/>
                </xsl:when>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'c')">
                    <xsl:value-of select="'c'"/>
                </xsl:when>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'd')">
                    <xsl:value-of select="'d'"/>
                </xsl:when>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'e')">
                    <xsl:value-of select="'e'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <anchor xml:id="{concat(translate($target, ' :-(),', ''), '.',$fnnumber, $char, '_A')}">
            <xsl:apply-templates/>
        </anchor>
    </xsl:template>

    <!-- ________________________anchor exception handling________________________ -->

    <!-- in two entries two images had the same IDs -->
    <!-- start new footnote counter by their position (anchors appear in the same order)
        -->

    <xsl:template
        match="article[lem[. eq 'Elektrizität']]//a[@href and ancestor::p/preceding-sibling::a[@name]]"
        priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate($lemma, $apos, '')"/>
        <xsl:variable name="fnnumber" select="replace(./@href, '^\D+', '')"/>
        <xsl:variable name="fnnumber" select="translate($fnnumber, ' ', '')"/>
        <ref type="image"
            target="{concat('#', translate($target, ' :-(),', ''), '.', $fnnumber, '_A_1')}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <xsl:template
        match="article[lem[. eq 'Elektrizität']]//a[@name and not(following-sibling::p[a[@href]])]"
        priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate($lemma, $apos, '')"/>

        <xsl:variable name="fnnumber"
            select="translate(./@name, translate(./@name, '0123456789', ''), '')"/>
        <xsl:variable name="char">
            <xsl:choose>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'a')">
                    <xsl:value-of select="'a'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <anchor xml:id="{concat(translate($target, ' :-(),', ''), '.', $fnnumber, $char, '_A_1')}">
            <xsl:apply-templates/>
        </anchor>
    </xsl:template>

    <xsl:template
        match="article[lem[. eq 'Nietverbindungen']]//a[@name and not(following-sibling::p)]"
        priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate($lemma, $apos, '')"/>
        <xsl:variable name="fnnumber"
            select="translate(./@name, translate(./@name, '0123456789', ''), '')"/>
        <xsl:variable name="char">
            <xsl:choose>
                <xsl:when test="contains(tokenize(./@name, '\d+')[last()], 'a')">
                    <xsl:value-of select="'a'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <anchor xml:id="{concat(translate($target, ' :-(),', ''), '.', $fnnumber, $char, '_A_1')}">
            <xsl:apply-templates/>
        </anchor>
    </xsl:template>

    <xsl:template
        match="article[lem[. eq 'Nietverbindungen']]//a[@href and ancestor::p/preceding-sibling::a]"
        priority="2">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' []:-();,', '')"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate($lemma, $apos, '')"/>
        <xsl:variable name="fnnumber" select="replace(./@href, '^\D+', '')"/>
        <xsl:variable name="fnnumber" select="replace($fnnumber, ' ', '')"/>
        <ref type="image"
            target="{concat('#', translate($target, ' :-(),', ''), '.', $fnnumber, '_A_1')}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <!-- ________________________entry structure - exception handling________________________  -->

    <!-- 2 errors were corrected:
            - footnotes of entry 'Drainage [1]' are not a descendant of their (supposed) <article> ancestor 
            - footnotes of 'Meridian' and 'Eisenbahnverkehr' (noticeable by their references) appear in other entries
            - (also in the original encyclopedias)
                
            - these three footnote groups are pulled into thei correct entries
            
            - for 'Meridian' and 'Eisbahnverkehr' this means a change of the encyclopedias' original structure
    -->

    <xsl:template match="articlegroup[not(contains(@name, '-')) and contains(@sort, 'yes')]/article">
        <xsl:variable name="lemma" select="translate(.//lem/text(), ' []:-();,', '')"/>
        <entry xml:id="{concat(generate-id(.), $crtUri)}" xml:lang="de">
            <form type="lemma">
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <xsl:apply-templates/>

                <xsl:if test=".//lem eq 'Drainage [1]'">
                    <xsl:for-each select="//fn[not(parent::text)]/fntext">
                        <xsl:variable name="fnnumber" select="./@name"/>
                        <note>
                            <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
                                <xsl:apply-templates/>
                            </note>
                        </note>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test=".//lem eq 'Meridian [1]'">
                    <xsl:for-each
                        select="//lem[. eq 'Meridiankonvergenz']/ancestor::article//fntext">
                        <xsl:variable name="fnnumber" select="./@name"/>
                        <note>
                            <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
                                <xsl:apply-templates/>
                            </note>
                        </note>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test=".//lem eq 'Eisenbahnverkehr'">
                    <note>
                        <xsl:for-each
                            select="//lem[. eq 'Eisenbahnverwaltung']/ancestor::article//fntext">
                            <xsl:variable name="fnnumber" select="./@name"/>

                            <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
                                <xsl:apply-templates/>
                            </note>
                        </xsl:for-each>
                    </note>
                </xsl:if>
            </sense>
        </entry>
    </xsl:template>

    <xsl:template match="fn[not(parent::text)]"/>

    <xsl:template match="table//fnref" priority="2"/>

    <xsl:template match="article[lem eq 'Meridiankonvergenz']//fn"/>
    <xsl:template match="article[lem eq 'Eisenbahnverwaltung']//fn"/>


</xsl:stylesheet>
