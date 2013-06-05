/**
 * The contents of this file are subject to the license and copyright detailed
 * in the LICENSE and NOTICE files at the root of the source tree and available
 * online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.authority;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.apache.log4j.Logger;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

// 05/06/2013 rtalbot this is not working correctly yet because of problems
// getting tablerowiterator (below) to behave. Close to it though

public class DSpaceAuthors implements ChoiceAuthority {

    private static Logger log = Logger.getLogger(DSpaceAuthors.class);

    /**
     * Our context
     */
    // constructor does static init too..
    public DSpaceAuthors() {
    }

    // punt!  this is a poor implementation..
    public Choices getBestMatch(String field, String text, int collection, String locale) {
        return getMatches(field, text, collection, 0, 2, locale);
    }

    /**
     * Match a proposed value against name authority records Value is assumed to
     * be in "Lastname, Firstname" format.
     */
    @Override
    public Choices getMatches(String field, String text, int collection, int start, int limit, String locale) {

        try {
            Choices result = queryPerson(text, start, limit);

            if (result == null) {
                result = new Choices(true);
                log.info("no choices");
            }

            return result;
        } catch (SQLException ex) {
            log.error(ex);
            // java.util.logging.Logger.getLogger(DSpaceAuthors.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    // punt; supposed to get the canonical display form of a metadata authority key
    // XXX FIXME implement this with a query on the authority key, cache results
    public String getLabel(String field, String key, String locale) {
        return key;
    }

    /**
     * Guts of the implementation, returns a complete Choices result, or null
     * for a failure.
     */
    private Choices queryPerson(String text, int start, int limit) throws SQLException {
        Choices choices = null;

        // punt if there is no query text
        if (text == null || text.trim().length() == 0) {
            log.info("no query");
            return new Choices(true);

        }


        // XXX arbitrary default limit - should be configurable?
        if (limit == 0) {
            limit = 50;
        }

        Context context = new Context();
        context.turnOffAuthorisationSystem();
        List<Choice>v = new ArrayList<Choice>();
        TableRowIterator tri = null;

        try {
            tri = DatabaseManager.query(context, "SELECT id, value FROM bi_2_dis");
            while (tri.hasNext()) {
                TableRow row = tri.next();
                v.add(new Choice(row.getStringColumn("id"),row.getStringColumn("value") , row.getStringColumn("value")));
                log.info("ID" +row.getStringColumn("id") + "value" + row.getStringColumn("value"));
            }
            
            //tri.close();
            Choice[] values;
            values = v.toArray(new Choice[v.size()]);
            choices = new Choices(values, 0, values.length, Choices.CF_AMBIGUOUS, false);
        } catch (SQLException sqle) {
            log.error(sqle);
            // Handle database error
        }



        //int confidence;
        //if (handler.hits == 0)
        //{
        //    confidence = Choices.CF_NOTFOUND;
        //}
        //else if (handler.hits == 1)
        //{
        //    confidence = Choices.CF_UNCERTAIN;
        //}
        //else
        //{
        //    confidence = Choices.CF_AMBIGUOUS;
        //}

        String values[] = {
            "Rubble,Barney",
            "Flintstone Fred",
            "Rubble, Wilma",
            "Rubble,Pebbles"};
        String labels[] = {
            "Rubble,Barney",
            "Flintstone,Fred",
            "Rubble,Wilma",
            "Rubble,Pebbles"};

        //Choice v[] = new Choice[values.length];
        for (int i = 0; i < values.length; ++i) {
            //log.info("adding" + values[i]);
           // v[i] = new Choice(String.valueOf(i), values[i], labels[i]);
        }


        //String mylccn= "abcde";
        //String myname = "Rubble,Barney";
        //handler.result.add(new Choice(mylccn, myname, myname));
      //  return new Choices(v, 0, v.length, Choices.CF_AMBIGUOUS, false);
return choices;
        //return new Choices(true);
    }
}
