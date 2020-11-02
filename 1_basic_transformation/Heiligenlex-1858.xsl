<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:variable name="file" select="document('Heiligenlexikon-1858-000.xml')"/> 
    <xsl:variable name="part2" select="document('Heiligenlexikon-1858-002-2.xml')"/> 
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:import href="preface.xsl"/>
    
    <!-- Note: some footnotes in the original files are not grouped by a <p> tag.
            These footnotes were changed manually, so that the content of one footnote would be in exactly one <p> tag. -->


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
                            <xsl:value-of select="$file/doc//div[@class = 'zenoCOTitles']/h3[2]"/>
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
                                select="$file//articlegroup[@name = '-']//h3 | $file//articlegroup[@name = '-']//h2">
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
                        <xsl:for-each select="$file//articlegroup[@name = 'M']/article">
                            <div>
                                <head>
                                    <xsl:value-of select=".//lem"/>
                                </head>
                                <xsl:for-each select=".//p[not(preceding-sibling::h4[string-join(.//text()) eq 'Fußnoten'])]|.//h4">
                                    <p>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:for-each>
                                <div>
                                    <xsl:for-each select=".//p[descendant::plink[not(child::sup)]]">
                                        <xsl:variable name="lem"
                                            select="tokenize(.//plink/@href, '/')[last()]"/>
                                        <xsl:variable name="lemma"
                                            select="translate(tokenize($lem, '#')[1], ' :-()[];,', '')"/>
                                        <xsl:variable name="fnnumber" select=".//plink/text()"/>
                                        <xsl:variable name="id"
                                            select="concat($lemma, '.', $fnnumber)"/>
                                        <p>
                                            <note xml:id="{concat($lemma,'.', $fnnumber)}" type='footnote'>
                                                <xsl:apply-templates/>
                                                <xsl:if
                                                  test="$id = 'Einleitungzum2.Band.51' or $id = 'Einleitungzum2.Band.65'">
                                                  <xsl:for-each
                                                  select="following-sibling::p[not(child::pname)][position() lt 7]">
                                                  <lb/>
                                                  <xsl:apply-templates/>
                                                  </xsl:for-each>
                                                </xsl:if>
                                            </note>
                                        </p>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </xsl:for-each>
                      
                    </div>
                </front>
                <body>
                    <div>
                        <xsl:apply-templates/>
                    </div>
                    <div>
                        <xsl:apply-templates select="$part2//articlegroup[@name='A']/node()"/>
                    </div>
                </body>
                <back> 
                    <xsl:apply-templates select="$part2//articlegroup[@name='M']"/>
                </back>
            </text>
        </TEI>
    </xsl:template>
 
    <!-- ________________________references________________________ -->
    <xsl:template match="article/text//i[(contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -6),  ' s. ')
        or contains(substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]) -4),  'S. ')
        or contains(substring(following-sibling::text()[1], 1,7),  's.d.'))]">
        <xsl:variable name="lemma" select="string-join(.//text()[not(parent::sup)])"/>
        
        <xsl:variable name="number" select="./sup/text()"/>
        <xsl:variable name="name" select="replace(tokenize($lemma, ' ')[2], '\.', '')"/>
        <xsl:variable name="krzl" select="tokenize($lemma, ' ')[1]"/>
        <!--<xsl:value-of select="count($number)"/>
        <xsl:value-of select="$number"/>-->
        <xsl:choose>
            <xsl:when test="count($krzl) = 1">
                <xsl:variable name="name" select="concat($name,', ',$krzl)"/>
                <xsl:choose>
                    <xsl:when test="count($number) = 1">
                        <xsl:variable name="name" select="concat($name,' (', $number, ')')"/>
                        <ref type='entry' target= '{$name}'>
                            <hi rend='italic'>
                            <xsl:apply-templates/>
                            </hi>
                        </ref>
                    </xsl:when>
                    <xsl:otherwise>
                        <ref type='entry' target= '{$name}'>
                            <hi rend='italic'>
                                <xsl:apply-templates/>
                            </hi>
                        </ref>
                    </xsl:otherwise>
                </xsl:choose>
             
            </xsl:when>
            <xsl:otherwise>
                <ref type='entry' target= '{$name}'>
                    <hi rend='italic'>
                        <xsl:apply-templates/>
                    </hi>
                </ref>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="lb"/>

    <!-- ________________________footnote handling________________________  -->

    <!-- footnotes are listed after one letter
            - footnotes are pulled into their corresponding entries
    -->

    <xsl:template match="plink[child::sup]">
        <xsl:variable name="lemma"
            select="translate(./ancestor::article/lem/text(), ' :-()[];,', '')"/>
        <xsl:variable name="fnnumber" select="./sup/text()"/>
        <ref type='footnote' target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>

    <xsl:template match="$file//p[descendant::plink[not(child::sup)]]" priority="2">
        <xsl:variable name="lem" select="tokenize(.//plink/@href, '/')[last()]"/>
        <xsl:variable name="lemma" select="translate(tokenize($lem, '#')[1], ' :-()[];,', '')"/>
        <xsl:variable name="fnnumber" select=".//plink/text()"/>
        <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
            <xsl:apply-templates/>
        </note>
    </xsl:template>

    <xsl:template match="p[descendant::plink[not(child::sup)]]" priority="2"/>

    <xsl:template match="table//fnref" priority="2"/>

    <!-- ________________________basic entry structure________________________ -->

    <xsl:template match="article">

        <xsl:variable name="entry" select="translate(./lem/text(), ' :-()[];,', '')"/>

        <entry xml:id="{concat(generate-id(.), $crtUri)}" xml:lang="de">
            <form type="lemma">
                <term>
                    <xsl:value-of select=".//lem"/>
                </term>
            </form>
            <sense xml:id="{generate-id(.)}">
                <xsl:apply-templates/>
                <note>
                    <xsl:for-each
                        select="./following-sibling::article[descendant::plink[not(child::sup)]][1]/text/p">
                        <xsl:variable name="lem" select="tokenize(./plink/@href, '/')[last()]"/>
                        <xsl:variable name="lemma"
                            select="translate(tokenize($lem, '#')[1], ' :-()[];,', '')"/>
                        <xsl:variable name="fnnumber" select=".//plink/text()"/>
                        <xsl:choose>
                            <xsl:when test="$entry = $lemma">
                                <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
                                    <xsl:apply-templates/>
                                    <xsl:if test="$fnnumber = '23'">
                                        <xsl:for-each
                                            select="following-sibling::p[not(child::plink)]">
                                            <lb/>
                                            <xsl:value-of select="."/>
                                        </xsl:for-each>
                                    </xsl:if>
                                </note>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </note>
            </sense>
        </entry>
    </xsl:template>
    
    <!-- ________________________verse________________________ -->
    
    <xsl:key name="kFollowing" match="p[preceding-sibling::*[1][self::p] and child::span]"
        use="
        generate-id(preceding-sibling::p
        [not(preceding-sibling::*[1][self::p]) and child::span][1])"/>
    
    <xsl:template
        match="
        p
        [not(preceding-sibling::*[1][self::p[child::span]]) and child::span and not(
        contains(ancestor::article/lem/text(), 'Kaddroë') or
        contains(ancestor::article/lem/text(), 'Juvanus') or
        contains(ancestor::article/lem/text(), 'Justitia') or
        contains(ancestor::article/lem/text(), 'Jovianus') or
        contains(ancestor::article/lem/text(), 'Joseph') or
        ancestor::article/lem/text() eq 'Johannes Endes (994)'or
        ancestor::article/lem/text() eq 'Johannes (940)')
        ]">
        <def>
            <lg>
                <xsl:call-template name="p"/>
                <xsl:apply-templates mode="copy1" select="key('kFollowing', generate-id())"/>
            </lg>
        </def>
    </xsl:template>
    
    <xsl:template
        match="p[preceding-sibling::*[1][self::p[child::span]]]"/>
    
    <xsl:template match="p" mode="copy1">
        <xsl:call-template name="p"/>
    </xsl:template>
    
    <xsl:template match="p" mode="copy1" name="p">
        <l>
            <xsl:apply-templates/>
        </l>
    </xsl:template>

    <!-- ________________________appendix________________________ -->
    
    <xsl:template match="$part2//articlegroup[@name='M']">
        <xsl:apply-templates mode="back"/>
    </xsl:template>
    
    <xsl:template match="$part2//article/article" mode="back">
        <xsl:variable name="entry" select="translate(./lem/text(), ' :-()[];,', '')"/>
        <div>
                <head>
                    <xsl:value-of select=".//lem"/>
                </head>
                <xsl:apply-templates mode="back"/>
            <note>
                <xsl:for-each
                    select=".//p[descendant::plink[not(child::sup)]]">
                    <xsl:variable name="lem" select="tokenize(.//plink/@href, '/')[last()]"/>
                    <xsl:variable name="lemma"
                        select="translate(tokenize($lem, '#')[1], ' :-()[];,', '')"/>
                    <xsl:variable name="fnnumber" select=".//plink/text()"/>
                    <xsl:choose>
                        <xsl:when test="$entry = $lemma">
                            <xsl:variable name="lemma"
                                select="translate($lemma, '4', 'vierter')"/>
                            <xsl:variable name="lemma"
                                select="translate($lemma, '5', 'fuenfter')"/>
                            <note xml:id="{concat($lemma,'.', $fnnumber)}" type="footnote">
                                <xsl:apply-templates/>
                                <xsl:if test="$fnnumber = '23'">
                                    <xsl:for-each
                                        select="following-sibling::p[not(child::plink)]">
                                        <lb/>
                                        <xsl:value-of select="."/>
                                        
                                    </xsl:for-each>
                                </xsl:if>
                            </note>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </note>
        </div>
    </xsl:template>

    
    <xsl:template match="p" mode="back">
            <p>
                <xsl:apply-templates mode="back"/>
            </p>
    </xsl:template>

    <xsl:template match="lem" mode="back"/>

    <xsl:template match="h2 | h3 | h4 | h5" mode="back">
        <note type="header">
            <xsl:apply-templates mode="back"/>
        </note>
    </xsl:template>
    
    <xsl:template match="i" mode="back">
        <hi rend="italic">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>
    
    <xsl:template match="b" mode="back">
        <hi rend="bold">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>
   
    
    <xsl:template match="sub" mode="back">
        <hi rend="subscript">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>
    
    <xsl:template match="sup" mode="back">
        <hi rend="superscript">
            <xsl:apply-templates mode="back"/>
        </hi>
    </xsl:template>
    
    <xsl:template match="plink[child::sup]" mode='back'>
        <xsl:variable name="lemma"
            select="translate(./ancestor::article[not(child::article)]/lem/text(), ' :-()[];,', '')"/>
        <xsl:variable name="lemma"
            select="translate($lemma, '4', 'vierter')"/>
        <xsl:variable name="lemma"
            select="translate($lemma, '5', 'fuenfter')"/>
        <xsl:variable name="fnnumber" select="./sup/text()"/>
        <ref type='footnote' target="{concat('#',$lemma,'.', $fnnumber)}"/>
    </xsl:template>
    
    <xsl:template match="p[descendant::plink[not(child::sup)]]" mode='back' priority="2"/>

</xsl:stylesheet>
