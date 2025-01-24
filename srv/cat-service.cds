using my.bookshop as my from '../db/schema';

service CatalogService {
    @(requires: 'authenticated-user')
    entity Books      as projection on my.Books;

    @(requires: 'admin')
    entity Books1     as projection on my.Books;

    entity Booksample as projection on my.Books;
}
