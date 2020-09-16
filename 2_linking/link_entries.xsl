<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <!-- This stylesheet substitutes targets with entryID targes in <ref> -->

    <!-- There are instances RESEMBLING references in other encycs (or also in the ones already mentioned above) as well.
               those are very problematic to resolve though (e.g. Pataky) often due to very vague expressions as to what is referenced.
               References from that category also often have no match (not even by manual search).
    -->
    <!-- These refs may sometimes not have a target due to ambiguous references or no matches (see above) -->

    <!-- Encycs where linking is necessary: -->
    <!-- Brockhaus 1809, 1837, 1911, DamenConvLex, Eisler 1904, 1912, Herder, Lueger, Mauthner, Meyers, Roell, Schmidt, Sulzer, Vollmer, Wander -->
    <!-- Hederich, KM -->


    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'entry' and @target]" priority="2">
        <xsl:variable name="lemma" select="@target"/>
        <xsl:variable name="lemma2" select="string-join(./text())"/>
        <xsl:variable name="id" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]/@xml:id"/>
        <xsl:variable name="id2" select="//tei:entry[./tei:form/tei:term/text() eq $lemma2]/@xml:id"/>
        <xsl:choose>
            <xsl:when test="count($id) = 1">
                <ref type="entry" target="#{$id}">

                    <xsl:apply-templates/>
                </ref>
            </xsl:when>
            <xsl:when test="count($id2) = 1">

                <ref type="entry" target="#{$id2}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:when>
            <xsl:otherwise>

                <xsl:choose>
                    <!-- what if no ID can be found -->
                    <xsl:when test="empty($id)">

                        <xsl:choose>
                            <xsl:when test="string-length($lemma) > string-length($id)">
                                <xsl:variable name="id"
                                    select="//tei:entry[contains($lemma, ./tei:form/tei:term/text())]/@xml:id"/>

                                <xsl:choose>
                                    <xsl:when test="empty($id) or count($id) > 1">
                                        <xsl:variable name="lemma" select="string-join(./text())"/>
                                        <xsl:variable name="id"
                                            select="//tei:entry[contains($lemma, ./tei:form/tei:term/text())]/@xml:id"/>

                                        <xsl:choose>
                                            <xsl:when test="count($id) = 1">
                                                <ref type="entry" target="#{$id}">
                                                  <xsl:apply-templates/>
                                                </ref>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <ref type="entry">
                                                  <xsl:apply-templates/>
                                                </ref>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <ref type="entry" target="#{$id}">
                                            <xsl:apply-templates/>
                                        </ref>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>

                            <xsl:when test="string-length($id) > string-length($lemma)">
                                <xsl:variable name="id"
                                    select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma)]/@xml:id"/>

                                <xsl:choose>
                                    <xsl:when test="empty($id) or count($id) > 1">
                                        <xsl:variable name="lemma" select="./text()"/>
                                        <xsl:variable name="id"
                                            select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma)]/@xml:id"/>
                                        <xsl:choose>
                                            <xsl:when test="count($id) = 1">
                                                <ref type="entry" target="#{$id}">
                                                  <xsl:apply-templates/>
                                                </ref>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <ref type="entry">
                                                  <xsl:apply-templates/>
                                                </ref>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <ref type="entry" target="#{$id}">
                                            <xsl:apply-templates/>
                                        </ref>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>

                            <xsl:otherwise>
                                <!-- if all else fails -->
                                <ref type="entry" target="#{$id}">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>
                        <!-- it's a full match -->
                        <ref type="entry" target="#{$id}">
                            <xsl:apply-templates/>
                        </ref>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ______________________________General______________________________ -->
    <xsl:template
        match="
            doc('Brockhaus-1809.xml')//tei:ref[@type = 'entry'] |
            doc('Brockhaus-1837.xml')//tei:ref[@type = 'entry'] |
            doc('Mauthner-1923.xml')//tei:ref[@type = 'entry'] |
            doc('Lueger-1904.xml')//tei:ref[@type = 'entry'] |
            doc('Eisler-1904.xml')//tei:ref[@type = 'entry'] |
            doc('Hederich-1770.xml')//tei:ref[@type = 'entry'] |
            doc('Kirchner-Michaelis-1907.xml')//tei:ref[@type = 'entry']"
        priority="3">
        <xsl:variable name="lemma" select="@target"/>
        <xsl:variable name="term" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]"/>
        <xsl:variable name="id" select="$term/@xml:id"/>
        <xsl:choose>
            <xsl:when test="count($id) = 1">
                <ref type="entry" target="#{$id}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:when>

            <!-- what if no ID can be found -->
            <xsl:when test="empty($id) or count($id) > 1">
                <xsl:variable name="id"
                    select="//tei:entry[contains($lemma, ./tei:form/tei:term/text())]/@xml:id"/>
                <xsl:choose>
                    <xsl:when test="count($id) = 1">
                        <ref type="entry" target="#{$id}">
                            <xsl:apply-templates/>
                        </ref>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="id"
                            select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma)]/@xml:id"/>
                        <xsl:choose>
                            <xsl:when test="count($id) = 1">
                                <ref type="entry" target="#{$id}">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:when>
                            <xsl:otherwise>
                                <ref type="entry">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

        </xsl:choose>
    </xsl:template>

    <!-- ______________________________Heiligenlex______________________________ -->
    <xsl:template match="doc('Heiligenlex-1858.xml')//tei:ref[@type = 'entry']" priority="3">
        <xsl:variable name="lemma" select="replace(@target, '^, ', '')"/>
        <xsl:variable name="lemma" select="replace($lemma, '^\(\S+ ', '')"/>
        <xsl:variable name="lemma" select="replace($lemma, '([a-z])(\.)', '$1')"/>
        <xsl:variable name="term" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]"/>
        <xsl:variable name="id" select="$term/@xml:id"/>
        <xsl:choose>
            <xsl:when test="count($id) = 1">
                <ref type="entry" target="#{$id}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="empty($id)">
                        <xsl:variable name="id"
                            select="//tei:entry[contains($lemma, ./tei:form/tei:term/text())]/@xml:id"/>
                        <xsl:choose>
                            <xsl:when test="count($id) = 1">
                                <ref type="entry" target="#{$id}">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="id"
                                    select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma)]/@xml:id"/>
                                <xsl:choose>
                                    <xsl:when test="count($id) = 1">
                                        <ref type="entry" target="#{$id}">
                                            <xsl:apply-templates/>
                                        </ref>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="lemma2"
                                            select="replace($lemma, ',? (S. )?\(', ', SS. (')"/>
                                        <xsl:variable name="term"
                                            select="//tei:entry[./tei:form/tei:term/text() eq $lemma2]"/>
                                        <xsl:variable name="id" select="$term/@xml:id"/>
                                        <xsl:choose>
                                            <xsl:when test="count($id) = 1">
                                                <xsl:variable name="dateref"
                                                  select="./ancestor::sense/substring(string-join(text()), 1, 17)"/>
                                                <xsl:variable name="dateterm"
                                                  select="$term/ancestor::entry//sense/substring(text()[1], 1, 17)"/>
                                                <xsl:variable name="dateref"
                                                  select="replace($dateref, '\).+|.+\(', '')"/>
                                                <xsl:variable name="dateterm"
                                                  select="replace($dateref, '\).+|.+\(', '')"/>
                                                <xsl:choose>
                                                  <xsl:when test="$dateref = $dateterm">
                                                  <ref type="entry" target="#{$id}">
                                                  <xsl:apply-templates/>
                                                  </ref>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <ref type="entry">
                                                  <xsl:apply-templates/>
                                                  </ref>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:variable name="lemma-term"
                                                  select="replace($lemma, ',? .*', '')"/>
                                                <xsl:variable name="lemma-number"
                                                  select="replace($lemma, '.+ (\(\d+\))', '$1')"/>
                                                <xsl:variable name="term"
                                                  select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma-term) and contains(./tei:form/tei:term/text(), $lemma-number)]"/>
                                                <xsl:variable name="id" select="$term/@xml:id"/>
                                                <xsl:choose>
                                                  <xsl:when test="count($id) = 1">
                                                  <xsl:variable name="dateref"
                                                  select="./ancestor::sense/substring(text()[1], 1, 17)"/>
                                                  <xsl:variable name="dateterm"
                                                  select="$term/ancestor::entry//sense/substring(text()[1], 1, 17)"/>
                                                  <xsl:variable name="dateref"
                                                  select="replace($dateref, '\).+|.+\(', '')"/>
                                                  <xsl:variable name="dateterm"
                                                  select="replace($dateref, '\).+|.+\(', '')"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$dateref = $dateterm">
                                                  <ref type="entry" target="#{$id}">
                                                  <xsl:apply-templates/>
                                                  </ref>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <ref type="entry">
                                                  <xsl:apply-templates/>
                                                  </ref>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:variable name="lemma-number"
                                                  select="replace($lemma, '.+ (\(\d+)\)', '$1')"/>
                                                  <xsl:variable name="term"
                                                  select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma-term) and contains(./tei:form/tei:term/text(), $lemma-number)]"/>
                                                  <xsl:variable name="id" select="$term/@xml:id"/>
                                                  <xsl:choose>
                                                  <xsl:when test="count($id) = 1">
                                                  <ref type="entry" target="{$id}">
                                                  <xsl:apply-templates/>
                                                  </ref>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <ref type="entry">
                                                  <xsl:apply-templates/>
                                                  </ref>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ______________________________Pataky______________________________ -->
    <xsl:template match="doc('Pataky-1898.xml')//tei:ref[@type = 'entry']" priority="3">

        <xsl:variable name="lemma2" select="./@target"/>
        <xsl:variable name="lemma2"
            select="replace($lemma2, ' z.| zu|Frau|Tochter|Gräfin|Freiin|deutsche|landwirtschaftliche', '')"/>
        <xsl:variable name="id2" select="//tei:entry[./tei:form/tei:term/text() eq $lemma2]/@xml:id"/>
        <xsl:choose>

            <xsl:when test="count($id2) = 1">
                <ref type="entry" target="#{$id2}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:when>
            <xsl:when test="empty($id2)">
                <xsl:variable name="lemma" select="tokenize($lemma2, ',')[1]"/>
                <xsl:variable name="lemma" select="normalize-space($lemma)"/>
                <xsl:variable name="id"
                    select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma)]/@xml:id"/>
                <xsl:choose>
                    <xsl:when test="count($id) = 1">
                        <ref type="entry" target="#{$id}">
                            <xsl:apply-templates/>
                        </ref>
                    </xsl:when>
                    <xsl:when test="count($id) > 1 or empty($id)">
                        <xsl:variable name="lemma" select="tokenize($lemma2, ',')[2]"/>
                        <xsl:variable name="lemma" select="normalize-space($lemma)"/>
                        <xsl:variable name="lemma" select="substring($lemma, 1, 3)"/>
                        <xsl:variable name="lemma" select="replace($lemma, ' v|\.| ', '')"/>
                        <xsl:variable name="lemmapre" select="tokenize($lemma2, ',')[1]"/>
                        <xsl:variable name="lemmapre" select="normalize-space($lemmapre)"/>
                        <xsl:variable name="lemmapre" select="substring($lemmapre, 1, 6)"/>
                        <xsl:variable name="lemmapre" select="replace($lemmapre, ' v|\.', '')"/>
                        <xsl:variable name="id"
                            select="//tei:entry[contains(./tei:form/tei:term/text(), $lemma) and contains(./tei:form/tei:term/text(), $lemmapre)]/@xml:id"/>
                        <xsl:choose>
                            <xsl:when test="count($id) = 1">
                                <ref type="entry" target="#{$id}">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when
                                        test="contains($lemma2, 'auch') and (contains($lemma2, 'Siehe') or contains($lemma2, 'S.'))">
                                        <ref type="external">
                                            <xsl:apply-templates/>
                                        </ref>
                                    </xsl:when>
                                    <xsl:when test="./text()">
                                        <ref type="entry">
                                            <xsl:apply-templates/>
                                        </ref>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <ref type="entry" target="{$lemma2}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ______________________________Meyers______________________________ -->
    <!-- Meyers without "contains" -->

    <xsl:template match="doc('Meyers-1905.xml')//tei:ref[@type = 'entry']" priority="3">

        <xsl:variable name="lemma" select="./text()"/>
        <xsl:variable name="lemma2" select="./@target"/>
        <xsl:variable name="id" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]/@xml:id"/>

        <xsl:choose>
            <xsl:when test="count($id) = 1">
                <ref type="entry" target="#{$id}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="id2"
                    select="//tei:entry[./tei:form/tei:term/text() eq $lemma2]/@xml:id"/>
                <ref type="entry" target="#{$id2}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Exceptions DamenConvLex -->
    <xsl:template match="tei:ref[@type = 'entry' and @target = 'Johanniskäfer u. Johanniswürmchen']"
        priority="3">
        <xsl:variable name="lemma">Johanniskäfer und Johanniswürmchen</xsl:variable>
        <xsl:variable name="id" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]/@xml:id"/>
        <ref type="entry" target="#{$id}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'entry' and @target = 'Theresia, Maria, die Kaiserin']"
        priority="3">
        <xsl:variable name="lemma">Theresia, Maria, Königin von Ungarn und Böhmen und Kaiserin von
            Oestreich</xsl:variable>
        <xsl:variable name="id" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]/@xml:id"/>
        <ref type="entry" target="#{$id}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'entry' and @target = 'Versöhnungsfest, lange Nacht']"
        priority="3">
        <xsl:variable name="lemma">Versöhnungsfest</xsl:variable>
        <xsl:variable name="id" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]/@xml:id"/>
        <ref type="entry" target="#{$id}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <xsl:template match="tei:ref[@type = 'entry' and @target = 'Fleischbrühe, Bouillon']"
        priority="3">
        <xsl:variable name="lemma">Fleischbrühe oder Bouillon</xsl:variable>
        <xsl:variable name="id" select="//tei:entry[./tei:form/tei:term/text() eq $lemma]/@xml:id"/>
        <ref type="entry" target="#{$id}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <!-- Exception Eisler - two entries with the same name -->
    <xsl:template match="tei:ref[@type = 'entry' and text() = 'Heinrich von Gent']" priority="3">
        <ref type="entry" target="#d2e21579Eisler-1912.xml">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <!-- give ID to figures as well -->
    <xsl:template match="tei:entry//tei:figure">
        <figure xml:id="{generate-id()}">
            <xsl:apply-templates/>
        </figure>
    </xsl:template>
</xsl:stylesheet>
