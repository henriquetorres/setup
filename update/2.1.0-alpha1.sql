SET FOREIGN_KEY_CHECKS = 0;

UPDATE `config` SET `value`='2.1.0-alpha1' WHERE `name`='thelia_version';
UPDATE `config` SET `value`='1' WHERE `name`='thelia_minus_version';
UPDATE `config` SET `value`='0' WHERE `name`='thelia_release_version';
UPDATE `config` SET `value`='alpha1' WHERE `name`='thelia_extra_version';


# ======================================================================================================================
# Add sale related tables
# ======================================================================================================================

-- ---------------------------------------------------------------------
-- sale
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `sale`;

CREATE TABLE `sale`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `active` TINYINT(1) DEFAULT 0 NOT NULL,
    `display_initial_price` TINYINT(1) DEFAULT 1 NOT NULL,
    `start_date` DATETIME,
    `end_date` DATETIME,
    `price_offset_type` TINYINT,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`),
    INDEX `idx_sales_active_start_end_date` (`active`, `start_date`, `end_date`),
    INDEX `idx_sales_active` (`active`)
) ENGINE=InnoDB CHARACTER SET='utf8';

-- ---------------------------------------------------------------------
-- sale_i18n
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `sale_i18n`;

CREATE TABLE `sale_i18n`
(
    `id` INTEGER NOT NULL,
    `locale` VARCHAR(5) DEFAULT 'en_US' NOT NULL,
    `title` VARCHAR(255),
    `description` LONGTEXT,
    `chapo` TEXT,
    `postscriptum` TEXT,
    `sale_label` VARCHAR(255),
    PRIMARY KEY (`id`,`locale`),
    CONSTRAINT `sale_i18n_FK_1`
        FOREIGN KEY (`id`)
        REFERENCES `sale` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';

-- ---------------------------------------------------------------------
-- sale_offset_currency
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `sale_offset_currency`;

CREATE TABLE `sale_offset_currency`
(
    `sale_id` INTEGER NOT NULL,
    `currency_id` INTEGER NOT NULL,
    `price_offset_value` FLOAT DEFAULT 0,
    PRIMARY KEY (`sale_id`,`currency_id`),
    INDEX `fk_sale_offset_currency_currency1_idx` (`currency_id`),
    CONSTRAINT `fk_sale_offset_currency_sales_id`
        FOREIGN KEY (`sale_id`)
        REFERENCES `sale` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_sale_offset_currency_currency_id`
        FOREIGN KEY (`currency_id`)
        REFERENCES `currency` (`id`)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';

-- ---------------------------------------------------------------------
-- sale_product
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `sale_product`;

CREATE TABLE `sale_product`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `sale_id` INTEGER NOT NULL,
    `product_id` INTEGER NOT NULL,
    `attribute_av_id` INTEGER,
    PRIMARY KEY (`id`),
    INDEX `fk_sale_product_product_idx` (`product_id`),
    INDEX `fk_sale_product_attribute_av_idx` (`attribute_av_id`),
    INDEX `idx_sale_product_sales_id_product_id` (`sale_id`, `product_id`),
    CONSTRAINT `fk_sale_product_sales_id`
        FOREIGN KEY (`sale_id`)
        REFERENCES `sale` (`id`)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT `fk_sale_product_product_id`
        FOREIGN KEY (`product_id`)
        REFERENCES `product` (`id`)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT `fk_sale_product_attribute_av_id`
        FOREIGN KEY (`attribute_av_id`)
        REFERENCES `attribute_av` (`id`)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';


# ======================================================================================================================
# Product sale elements images and documents
# ======================================================================================================================

-- ---------------------------------------------------------------------
-- product_sale_elements_product_image
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `product_sale_elements_product_image`;

CREATE TABLE `product_sale_elements_product_image`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `product_sale_elements_id` INTEGER NOT NULL,
    `product_image_id` INTEGER NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `fk_pse_product_image_product_image_id_idx` (`product_image_id`),
    INDEX `fk_pse_product_image_product_sale_element_idx` (`product_sale_elements_id`),
    CONSTRAINT `fk_pse_product_image_product_sale_elements_id`
        FOREIGN KEY (`product_sale_elements_id`)
        REFERENCES `product_sale_elements` (`id`),
    CONSTRAINT `fk_pse_product_image_product_image_id`
        FOREIGN KEY (`product_image_id`)
        REFERENCES `product_image` (`id`)
) ENGINE=InnoDB CHARACTER SET='utf8';

-- ---------------------------------------------------------------------
-- product_sale_elements_product_document
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `product_sale_elements_product_document`;

CREATE TABLE `product_sale_elements_product_document`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `product_sale_elements_id` INTEGER NOT NULL,
    `product_document_id` INTEGER NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `fk_pse_product_document_product_document__idx` (`product_document_id`),
    INDEX `fk_pse_product_document_product_sale_elem_idx` (`product_sale_elements_id`),
    CONSTRAINT `fk_pse_product_document_product_sale_elements_id`
        FOREIGN KEY (`product_sale_elements_id`)
        REFERENCES `product_sale_elements` (`id`),
    CONSTRAINT `fk_pse_product_document_product_document_id`
        FOREIGN KEY (`product_document_id`)
        REFERENCES `product_document` (`id`)
) ENGINE=InnoDB CHARACTER SET='utf8';


# ======================================================================================================================
# Hooks
# ======================================================================================================================

SELECT @max_pos := IFNULL(MAX(`position`),0) FROM `module`;
SELECT @max_id := IFNULL(MAX(`id`),0) FROM `module`;

INSERT INTO `module` (`id`, `code`, `type`, `activate`, `position`, `full_namespace`, `created_at`, `updated_at`) VALUES
  (@max_id+1, 'HookNavigation', 1, 1, @max_pos+1, 'HookNavigation\\HookNavigation', NOW(), NOW()),
  (@max_id+2, 'HookCurrency', 1, 1, @max_pos+2, 'HookCurrency\\HookCurrency', NOW(), NOW()),
  (@max_id+3, 'HookLang', 1, 1, @max_pos+3, 'HookLang\\HookLang', NOW(), NOW()),
  (@max_id+4, 'HookSearch', 1, 1, @max_pos+4, 'HookSearch\\HookSearch', NOW(), NOW()),
  (@max_id+5, 'HookCustomer', 1, 1, @max_pos+5, 'HookCustomer\\HookCustomer', NOW(), NOW()),
  (@max_id+6, 'HookCart', 1, 1, @max_pos+6, 'HookCart\\HookCart', NOW(), NOW()),
  (@max_id+7, 'HookAnalytics', 1, 1, @max_pos+7, 'HookAnalytics\\HookAnalytics', NOW(), NOW()),
  (@max_id+8, 'HookContact', 1, 1, @max_pos+8, 'HookContact\\HookContact', NOW(), NOW()),
  (@max_id+9, 'HookLinks', 1, 1, @max_pos+9, 'HookLinks\\HookLinks', NOW(), NOW()),
  (@max_id+10, 'HookNewsletter', 1, 1, @max_pos+10, 'HookNewsletter\\HookNewsletter', NOW(), NOW()),
  (@max_id+11, 'HookSocial', 1, 1, @max_pos+11, 'HookSocial\\HookSocial', NOW(), NOW()),
  (@max_id+12, 'HookProductsNew', 1, 1, @max_pos+12, 'HookProductsNew\\HookProductsNew', NOW(), NOW()),
  (@max_id+13, 'HookProductsOffer', 1, 1, @max_pos+13, 'HookProductsOffer\\HookProductsOffer', NOW(), NOW())
;

INSERT INTO  `module_i18n` (`id`, `locale`, `title`, `description`, `chapo`, `postscriptum`) VALUES
  (@max_id+1, 'en_US',  'Navigation block', NULL,  NULL,  NULL),
  (@max_id+1, 'fr_FR',  'Bloc menu', NULL,  NULL,  NULL),
  (@max_id+2,  'en_US',  'Currency block', NULL,  NULL,  NULL),
  (@max_id+2,  'fr_FR',  'Bloc des devises', NULL,  NULL,  NULL),
  (@max_id+3,  'en_US',  'Languages block', NULL,  NULL,  NULL),
  (@max_id+3,  'fr_FR',  'Bloc des langues', NULL,  NULL,  NULL),
  (@max_id+4,  'en_US',  'Search block', NULL,  NULL,  NULL),
  (@max_id+4,  'fr_FR',  'Bloc de recherche', NULL,  NULL,  NULL),
  (@max_id+5,  'en_US',  'Customer account block', NULL,  NULL,  NULL),
  (@max_id+5,  'fr_FR',  'Bloc compte client', NULL,  NULL,  NULL),
  (@max_id+6, 'en_US',  'Cart block', NULL,  NULL,  NULL),
  (@max_id+6, 'fr_FR',  'Bloc panier', NULL,  NULL,  NULL),
  (@max_id+7, 'en_US',  'Google Analytics block', NULL,  NULL,  NULL),
  (@max_id+7, 'fr_FR',  'Bloc Google Analytics', NULL,  NULL,  NULL),
  (@max_id+8, 'en_US',  'Contact block', NULL,  NULL,  NULL),
  (@max_id+8, 'fr_FR',  'Bloc contact', NULL,  NULL,  NULL),
  (@max_id+9, 'en_US',  'Links block', NULL,  NULL,  NULL),
  (@max_id+9, 'fr_FR',  'Bloc liens', NULL,  NULL,  NULL),
  (@max_id+10, 'en_US',  'Newsletter block', NULL,  NULL,  NULL),
  (@max_id+10, 'fr_FR',  'Bloc newsletter', NULL,  NULL,  NULL),
  (@max_id+11, 'en_US',  'Social Networks block', NULL,  NULL,  NULL),
  (@max_id+11, 'fr_FR',  'Bloc réseaux sociaux', NULL,  NULL,  NULL),
  (@max_id+12, 'en_US',  'New Products block', NULL,  NULL,  NULL),
  (@max_id+12, 'fr_FR',  'Bloc nouveaux produits', NULL,  NULL,  NULL),
  (@max_id+13, 'en_US',  'Products offer block', NULL,  NULL,  NULL),
  (@max_id+13, 'fr_FR',  'Bloc promotions', NULL,  NULL,  NULL)
;


-- ---------------------------------------------------------------------
-- hook
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `hook`;

CREATE TABLE `hook`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `code` VARCHAR(255) NOT NULL,
    `type` TINYINT,
    `by_module` TINYINT(1),
    `native` TINYINT(1),
    `activate` TINYINT(1),
    `block` TINYINT(1),
    `position` INTEGER,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `code_UNIQUE` (`code`, `type`),
    INDEX `idx_module_activate` (`activate`)
) ENGINE=InnoDB CHARACTER SET='utf8';

-- ---------------------------------------------------------------------
-- module_hook
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `module_hook`;

CREATE TABLE `module_hook`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `module_id` INTEGER NOT NULL,
    `hook_id` INTEGER NOT NULL,
    `classname` VARCHAR(255),
    `method` VARCHAR(255),
    `active` TINYINT(1) NOT NULL,
    `hook_active` TINYINT(1) NOT NULL,
    `module_active` TINYINT(1) NOT NULL,
    `position` INTEGER NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_module_hook_active` (`active`),
    INDEX `fk_module_hook_module_id_idx` (`module_id`),
    INDEX `fk_module_hook_hook_id_idx` (`hook_id`),
    CONSTRAINT `fk_module_hook_module_id`
        FOREIGN KEY (`module_id`)
        REFERENCES `module` (`id`)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT `fk_module_hook_hook_id`
        FOREIGN KEY (`hook_id`)
        REFERENCES `hook` (`id`)
        ON UPDATE RESTRICT
        ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';


-- ---------------------------------------------------------------------
-- hook_i18n
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `hook_i18n`;

CREATE TABLE `hook_i18n`
(
    `id` INTEGER NOT NULL,
    `locale` VARCHAR(5) DEFAULT 'en_US' NOT NULL,
    `title` VARCHAR(255),
    `description` LONGTEXT,
    `chapo` TEXT,
    PRIMARY KEY (`id`,`locale`),
    CONSTRAINT `hook_i18n_FK_1`
        FOREIGN KEY (`id`)
        REFERENCES `hook` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';


INSERT INTO `hook` (`id`, `code`, `type`, `by_module`, `block`, `native`, `activate`, `position`, `created_at`, `updated_at`) VALUES
  (1, 'order-invoice.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2, 'order-invoice.delivery-address', 1, 1, 0, 1, 1, 1, NOW(), NOW()),
  (3, 'order-invoice.payment-extra', 1, 1, 0, 1, 1, 1, NOW(), NOW()),
  (4, 'order-invoice.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (5, 'order-invoice.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (6, 'order-invoice.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (7, 'order-invoice.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (8, 'order-payment-gateway.body', 1, 1, 0, 1, 1, 1, NOW(), NOW()),
  (9, 'order-payment-gateway.javascript', 1, 1, 0, 1, 1, 1, NOW(), NOW()),
  (10, 'order-payment-gateway.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (11, 'order-payment-gateway.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (12, 'order-payment-gateway.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (13, 'sitemap.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (14, 'currency.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (15, 'currency.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (16, 'currency.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (17, 'currency.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (18, 'currency.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (19, 'login.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (20, 'login.main-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (21, 'login.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (22, 'login.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (23, 'login.main-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (24, 'login.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (25, 'login.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (26, 'login.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (27, 'login.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (28, 'account-update.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (29, 'account-update.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (30, 'account-update.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (31, 'account-update.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (32, 'account-update.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (33, 'account-update.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (34, 'account-update.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (35, 'cart.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (36, 'cart.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (37, 'cart.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (38, 'cart.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (39, 'cart.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (40, 'contact.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (41, 'contact.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (42, 'contact.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (43, 'contact.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (44, 'contact.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (45, 'contact.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (46, 'contact.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (47, 'order-placed.body', 1, 1, 0, 1, 1, 1, NOW(), NOW()),
  (48, 'order-placed.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (49, 'order-placed.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (50, 'order-placed.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (51, 'search.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (52, 'search.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (53, 'search.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (54, 'register.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (55, 'register.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (56, 'register.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (57, 'register.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (58, 'register.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (59, 'register.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (60, 'register.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (61, 'password.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (62, 'password.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (63, 'password.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (64, 'password.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (65, 'password.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (66, 'password.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (67, 'password.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (68, 'language.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (69, 'language.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (70, 'language.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (71, 'language.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (72, 'language.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (73, 'contact.success', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (74, 'newsletter.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (75, 'newsletter.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (76, 'newsletter.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (77, 'newsletter.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (78, 'newsletter.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (79, 'badresponseorder.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (80, 'badresponseorder.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (81, 'badresponseorder.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (82, 'content.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (83, 'content.main-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (84, 'content.main-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (85, 'content.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (86, 'content.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (87, 'content.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (88, 'content.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (89, 'main.head-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (90, 'main.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (91, 'main.head-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (92, 'main.body-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (93, 'main.header-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (94, 'main.navbar-secondary', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (95, 'main.navbar-primary', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (96, 'main.header-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (97, 'main.content-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (98, 'main.content-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (99, 'main.footer-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (100, 'main.footer-body', 1, 0, 1, 1, 1, 1, NOW(), NOW()),
  (101, 'main.footer-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (102, 'main.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (103, 'main.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (104, 'main.body-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (105, '404.content', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (106, '404.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (107, '404.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (108, '404.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (109, 'order-delivery.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (110, 'order-delivery.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (111, 'order-delivery.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (112, 'order-delivery.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (113, 'order-delivery.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (114, 'order-delivery.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (115, 'order-delivery.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (116, 'address-create.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (117, 'address-create.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (118, 'address-create.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (119, 'address-create.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (120, 'address-create.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (121, 'address-create.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (122, 'address-create.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (123, 'folder.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (124, 'folder.main-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (125, 'folder.main-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (126, 'folder.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (127, 'folder.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (128, 'folder.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (129, 'folder.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (130, 'order-failed.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (131, 'order-failed.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (132, 'order-failed.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (133, 'order-failed.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (134, 'order-failed.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (135, 'category.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (136, 'category.main-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (137, 'category.main-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (138, 'category.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (139, 'category.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (140, 'category.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (141, 'category.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (142, 'address-update.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (143, 'address-update.form-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (144, 'address-update.form-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (145, 'address-update.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (146, 'address-update.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (147, 'address-update.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (148, 'address-update.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (149, 'home.body', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (150, 'home.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (151, 'home.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (152, 'home.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (153, 'account-password.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (154, 'account-password.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (155, 'account-password.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (156, 'account-password.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (157, 'account-password.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (158, 'product.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (159, 'product.gallery', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (160, 'product.details-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (161, 'product.details-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (162, 'product.additional', 1, 0, 1, 1, 1, 1, NOW(), NOW()),
  (163, 'product.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (164, 'product.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (165, 'product.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (166, 'product.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (167, 'account.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (168, 'account.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (169, 'account.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (170, 'account.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (171, 'account.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (172, 'viewall.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (173, 'viewall.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (174, 'viewall.stylesheet', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (175, 'viewall.after-javascript-include', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (176, 'viewall.javascript-initialization', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (177, 'singleproduct.top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (178, 'singleproduct.bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (179, 'category.sidebar-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (180, 'category.sidebar-body', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (181, 'category.sidebar-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (182, 'content.sidebar-top', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (183, 'content.sidebar-body', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (184, 'content.sidebar-bottom', 1, 0, 0, 1, 1, 1, NOW(), NOW()),
  (185, 'order-delivery.extra', 1, 1, 0, 1, 1, 1, NOW(), NOW()),
  (186, 'order-delivery.javascript', 1, 1, 0, 1, 1, 1, NOW(), NOW()),

  (1000, 'category.tab-content', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1001, 'content.tab-content', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1002, 'folder.tab-content', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1003, 'order.tab-content', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1004, 'product.tab-content', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1005, 'features-value.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1006, 'features-value.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1007, 'feature.value-create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1008, 'feature.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1009, 'product.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1010, 'coupon.create-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1011, 'taxes.update-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1012, 'tax-rule.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1013, 'tools.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1014, 'tools.col1-top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1015, 'tools.col1-bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1016, 'tools.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1017, 'tools.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1018, 'messages.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1019, 'messages.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1020, 'messages.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1021, 'messages.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1022, 'message.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1023, 'message.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1024, 'messages.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1025, 'taxes-rules.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1026, 'taxes-rules.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1027, 'tax.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1028, 'tax.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1029, 'tax-rule.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1030, 'tax-rule.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1031, 'taxes-rules.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1032, 'exports.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1033, 'exports.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1034, 'exports.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1035, 'exports.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1036, 'export.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1037, 'product.folders-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1038, 'product.folders-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1039, 'product.details-pricing-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1040, 'product.details-details-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1041, 'product.details-promotion-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1042, 'product.before-combinations', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1043, 'product.combinations-list-caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1044, 'product.after-combinations', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1045, 'product.combination-delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1046, 'modules.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1047, 'modules.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1048, 'currency.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1049, 'category.contents-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1050, 'category.contents-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1051, 'category.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1052, 'document.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1053, 'customer.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1054, 'customers.caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1055, 'customers.header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1056, 'customers.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1057, 'customer.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1058, 'customer.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1059, 'customer.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1060, 'customers.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1061, 'product.contents-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1062, 'product.contents-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1063, 'product.accessories-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1064, 'product.accessories-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1065, 'product.categories-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1066, 'product.categories-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1067, 'product.attributes-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1068, 'product.attributes-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1069, 'product.features-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1070, 'product.features-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1071, 'template.attributes-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1072, 'template.attributes-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1073, 'template.features-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1074, 'template.features-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1075, 'templates.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1076, 'templates.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1077, 'templates.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1078, 'templates.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1079, 'template.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1080, 'template.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1081, 'templates.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1082, 'configuration.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1083, 'configuration.catalog-top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1084, 'configuration.catalog-bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1085, 'configuration.shipping-top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1086, 'configuration.shipping-bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1087, 'configuration.system-top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1088, 'configuration.system-bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1089, 'configuration.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1090, 'configuration.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1091, 'index.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1092, 'index.middle', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1093, 'index.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1094, 'orders.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1095, 'orders.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1096, 'orders.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1097, 'orders.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1098, 'orders.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1099, 'shipping-zones.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1100, 'shipping-zones.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1101, 'shipping-zones.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1102, 'shipping-zones.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1103, 'shipping-zones.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1104, 'content.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1105, 'home.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1106, 'home.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1107, 'home.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1108, 'modules.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1109, 'modules.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1110, 'modules.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1111, 'languages.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1112, 'languages.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1113, 'language.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1114, 'languages.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1115, 'languages.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1116, 'zone.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1117, 'shipping-zones.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1118, 'system.logs-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1119, 'search.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1120, 'search.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1121, 'search.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1122, 'administrators.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1123, 'administrators.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1124, 'administrator.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1125, 'administrator.update-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1126, 'administrator.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1127, 'administrators.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1128, 'module-hook.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1129, 'shipping-configuration.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1130, 'shipping-configuration.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1131, 'shipping-configuration.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1132, 'shipping-configuration.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1133, 'shipping-configuration.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1134, 'shipping-configuration.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1135, 'shipping-configuration.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1136, 'features.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1137, 'features.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1138, 'features.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1139, 'features.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1140, 'feature.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1141, 'feature.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1142, 'feature.add-to-all-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1143, 'feature.remove-to-all-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1144, 'features.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1145, 'module.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1146, 'module-hook.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1147, 'module-hook.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1148, 'module-hook.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1149, 'shipping-configuration.edit', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1150, 'shipping-configuration.country-delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1151, 'shipping-configuration.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1152, 'mailing-system.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1153, 'mailing-system.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1154, 'mailing-system.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1155, 'categories.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1156, 'categories.caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1157, 'categories.header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1158, 'categories.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1159, 'products.caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1160, 'products.header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1161, 'products.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1162, 'categories.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1163, 'categories.catalog-bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1164, 'category.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1165, 'product.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1166, 'category.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1167, 'product.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1168, 'categories.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1169, 'variables.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1170, 'variables.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1171, 'variables.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1172, 'variables.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1173, 'variable.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1174, 'variable.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1175, 'variables.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1176, 'order.product-list', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1177, 'order.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1178, 'config-store.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1179, 'translations.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1180, 'folders.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1181, 'folders.caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1182, 'folders.header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1183, 'folders.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1184, 'contents.caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1185, 'contents.header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1186, 'contents.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1187, 'folders.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1188, 'folder.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1189, 'content.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1190, 'folder.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1191, 'content.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1192, 'folders.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1193, 'template.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1194, 'tax.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1195, 'hook.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1196, 'countries.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1197, 'countries.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1198, 'countries.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1199, 'countries.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1200, 'country.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1201, 'country.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1202, 'countries.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1203, 'currencies.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1204, 'currencies.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1205, 'currencies.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1206, 'currencies.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1207, 'currency.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1208, 'currency.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1209, 'currencies.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1210, 'customer.edit', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1211, 'customer.address-create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1212, 'customer.address-update-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1213, 'customer.address-delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1214, 'customer.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1215, 'attributes-value.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1216, 'attributes-value.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1217, 'attribute-value.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1218, 'attribute.id-delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1219, 'attribute.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1220, 'profiles.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1221, 'profiles.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1222, 'profile.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1223, 'profile.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1224, 'profiles.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1225, 'country.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1226, 'profile.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1227, 'variable.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1228, 'coupon.update-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1229, 'coupon.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1230, 'coupon.list-caption', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1231, 'coupon.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1232, 'coupon.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1233, 'coupon.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1234, 'coupon.list-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1235, 'module.configuration', 2, 1, 0, 1, 1, 1, NOW(), NOW()),
  (1236, 'module.config-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1237, 'message.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1238, 'image.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1239, 'attributes.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1240, 'attributes.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1241, 'attributes.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1242, 'attributes.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1243, 'attribute.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1244, 'attribute.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1245, 'attribute.add-to-all-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1246, 'attribute.remove-to-all-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1247, 'attributes.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1248, 'admin-logs.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1249, 'admin-logs.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1250, 'admin-logs.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1251, 'folder.edit-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1252, 'hooks.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1253, 'hooks.table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1254, 'hooks.table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1255, 'hooks.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1256, 'hook.create-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1257, 'hook.delete-form', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1258, 'hooks.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1259, 'main.head-css', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1260, 'main.before-topbar', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1261, 'main.inside-topbar', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1262, 'main.after-topbar', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1263, 'main.before-top-menu', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1264, 'main.in-top-menu-items', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1265, 'main.after-top-menu', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1266, 'main.before-footer', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1267, 'main.in-footer', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1268, 'main.after-footer', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1269, 'main.footer-js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1270, 'main.topbar-top', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1271, 'main.topbar-bottom', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1272, 'main.top-menu-customer', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1273, 'main.top-menu-order', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1274, 'main.top-menu-catalog', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1275, 'main.top-menu-content', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1276, 'main.top-menu-tools', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1277, 'main.top-menu-modules', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1278, 'main.top-menu-configuration', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1279, 'brand.edit-js', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1280, 'home.block', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1281, 'brands.top', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1282, 'brands.table-header', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1283, 'brands.table-row', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1284, 'brands.bottom', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1285, 'brand.create-form', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1286, 'brand.delete-form', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1287, 'brand.js', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1288, 'imports.top', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1289, 'imports.row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1290, 'imports.bottom', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1291, 'imports.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1292, 'import.js', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1293, 'brand.tab-content', 2, 0, 1, 1, 1, 1, NOW(), NOW()),
  (1294, 'customer.orders-table-header', 2, 0, 0, 1, 1, 1, NOW(), NOW()),
  (1295, 'customer.orders-table-row', 2, 0, 0, 1, 1, 1, NOW(), NOW()),

  (2001, 'invoice.css', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2002, 'invoice.header', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2003, 'invoice.footer-top', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2004, 'invoice.imprint', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2005, 'invoice.footer-bottom', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2006, 'invoice.information', 3, 0, 1, 1, 1, 1, NOW(), NOW()),
  (2007, 'invoice.after-information', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2008, 'invoice.delivery-address', 3, 1, 0, 1, 1, 1, NOW(), NOW()),
  (2009, 'invoice.after-addresses', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2010, 'invoice.after-products', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2011, 'invoice.after-summary', 3, 0, 0, 1, 1, 1, NOW(), NOW()),

  (2012, 'delivery.css', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2013, 'delivery.header', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2014, 'delivery.footer-top', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2015, 'delivery.imprint', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2016, 'delivery.footer-bottom', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2017, 'delivery.information', 3, 0, 1, 1, 1, 1, NOW(), NOW()),
  (2018, 'delivery.after-information', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2019, 'delivery.delivery-address', 3, 1, 0, 1, 1, 1, NOW(), NOW()),
  (2020, 'delivery.after-addresses', 3, 0, 0, 1, 1, 1, NOW(), NOW()),
  (2021, 'delivery.after-summary', 3, 0, 0, 1, 1, 1, NOW(), NOW()),

  (2022, 'order-placed.additional-payment-info', 1, 1, 0, 1, 1, 1, NOW(), NOW()),

  (2023, 'wysywyg.js', 2, 0, 0, 1, 0, 1, NOW(), NOW())
;


INSERT INTO  `hook_i18n` (`id`, `locale`, `title`, `description`, `chapo`) VALUES
  (1, 'fr_FR', 'Choix du mode de paiement - en haut', '', ''),
  (1, 'en_US', 'Invoice choice - at the top', '', ''),
  (2, 'fr_FR', 'Choix du mode de paiement - adresse de livraison', '', ''),
  (2, 'en_US', 'Invoice choice - delivery address', '', ''),
  (3, 'fr_FR', 'Choix du mode de paiement - zone de paiement supplémentaire', '', ''),
  (3, 'en_US', 'Invoice choice - extra payment zone', '', ''),
  (4, 'fr_FR', 'Choix du mode de paiement - en bas', '', ''),
  (4, 'en_US', 'Invoice choice - at the bottom', '', ''),
  (5, 'fr_FR', 'Choix du mode de paiement - après l\'initialisation du javascript', '', ''),
  (5, 'en_US', 'Invoice choice - after javascript initialisation', '', ''),
  (6, 'fr_FR', 'Choix du mode de paiement - feuille de style CSS', '', ''),
  (6, 'en_US', 'Invoice choice - CSS stylesheet', '', ''),
  (7, 'fr_FR', 'Choix du mode de paiement - après l\'inclusion des javascript', '', ''),
  (7, 'en_US', 'Invoice choice - after javascript include', '', ''),
  (8, 'fr_FR', 'Passerelle de paiement - zone principale', '', ''),
  (8, 'en_US', 'Payment gateway - main area', '', ''),
  (9, 'fr_FR', 'Passerelle de paiement - javascript', '', ''),
  (9, 'en_US', 'Payment gateway - javascript', '', ''),
  (10, 'fr_FR', 'Passerelle de paiement - après l\'initialisation du javascript', '', ''),
  (10, 'en_US', 'Payment gateway - after javascript initialisation', '', ''),
  (11, 'fr_FR', 'Passerelle de paiement - feuille de style CSS', '', ''),
  (11, 'en_US', 'Payment gateway - CSS stylesheet', '', ''),
  (12, 'fr_FR', 'Passerelle de paiement - après l\'inclusion des javascript', '', ''),
  (12, 'en_US', 'Payment gateway - after javascript include', '', ''),
  (13, 'fr_FR', 'Sitemap - en bas', '', ''),
  (13, 'en_US', 'Sitemap - at the bottom', '', ''),
  (14, 'fr_FR', 'Page du choix de la device - en haut', '', ''),
  (14, 'en_US', 'Curency selection page - at the top', '', ''),
  (15, 'fr_FR', 'Page du choix de la device - en bas', '', ''),
  (15, 'en_US', 'Curency selection page - at the bottom', '', ''),
  (16, 'fr_FR', 'Page du choix de la device - feuille de style CSS', '', ''),
  (16, 'en_US', 'Curency selection page - CSS stylesheet', '', ''),
  (17, 'fr_FR', 'Page du choix de la device - après l\'inclusion des javascript', '', ''),
  (17, 'en_US', 'Curency selection page - after javascript include', '', ''),
  (18, 'fr_FR', 'Page du choix de la device - après l\'initialisation du javascript', '', ''),
  (18, 'en_US', 'Curency selection page - after javascript initialisation', '', ''),
  (19, 'fr_FR', 'Page de connexion - en haut', '', ''),
  (19, 'en_US', 'Login page - at the top', '', ''),
  (20, 'fr_FR', 'Page de connexion - en haut de la zone principal', '', ''),
  (20, 'en_US', 'Login page - at the top of the main area', '', ''),
  (21, 'fr_FR', 'Page de connexion - en haut du formulaire', '', ''),
  (21, 'en_US', 'Login page - at the top of the form', '', ''),
  (22, 'fr_FR', 'Page de connexion - en bas du formulaire', '', ''),
  (22, 'en_US', 'Login page - at the bottom of the form', '', ''),
  (23, 'fr_FR', 'Page de connexion - en bas de la zone principal', '', ''),
  (23, 'en_US', 'Login page - at the bottom of the main area', '', ''),
  (24, 'fr_FR', 'Page de connexion - en bas', '', ''),
  (24, 'en_US', 'Login page - at the bottom', '', ''),
  (25, 'fr_FR', 'Page de connexion - feuille de style CSS', '', ''),
  (25, 'en_US', 'Login page - CSS stylesheet', '', ''),
  (26, 'fr_FR', 'Page de connexion - après l\'inclusion des javascript', '', ''),
  (26, 'en_US', 'Login page - after javascript include', '', ''),
  (27, 'fr_FR', 'Page de connexion - après l\'initialisation du javascript', '', ''),
  (27, 'en_US', 'Login page - after javascript initialisation', '', ''),
  (28, 'fr_FR', 'Modification compte client - en haut', '', ''),
  (28, 'en_US', 'Update customer account - at the top', '', ''),
  (29, 'fr_FR', 'Modification compte client - en haut du formulaire', '', ''),
  (29, 'en_US', 'Update customer account - at the top of the form', '', ''),
  (30, 'fr_FR', 'Modification compte client - en bas du formulaire', '', ''),
  (30, 'en_US', 'Update customer account - at the bottom of the form', '', ''),
  (31, 'fr_FR', 'Modification compte client - en bas', '', ''),
  (31, 'en_US', 'Update customer account - at the bottom', '', ''),
  (32, 'fr_FR', 'Modification compte client - feuille de style CSS', '', ''),
  (32, 'en_US', 'Update customer account - CSS stylesheet', '', ''),
  (33, 'fr_FR', 'Modification compte client - après l\'inclusion des javascript', '', ''),
  (33, 'en_US', 'Update customer account - after javascript include', '', ''),
  (34, 'fr_FR', 'Modification compte client - après l\'initialisation du javascript', '', ''),
  (34, 'en_US', 'Update customer account - after javascript initialisation', '', ''),
  (35, 'fr_FR', 'Panier - en haut', '', ''),
  (35, 'en_US', 'Cart - at the top', '', ''),
  (36, 'fr_FR', 'Panier - en bas', '', ''),
  (36, 'en_US', 'Cart - at the bottom', '', ''),
  (37, 'fr_FR', 'Panier - après l\'inclusion des javascript', '', ''),
  (37, 'en_US', 'Cart - after javascript include', '', ''),
  (38, 'fr_FR', 'Panier - feuille de style CSS', '', ''),
  (38, 'en_US', 'Cart - CSS stylesheet', '', ''),
  (39, 'fr_FR', 'Panier - initialisation du javascript', '', ''),
  (39, 'en_US', 'Cart - javascript initialization', '', ''),
  (40, 'fr_FR', 'Page contact - en haut', '', ''),
  (40, 'en_US', 'Contact page - at the top', '', ''),
  (41, 'fr_FR', 'Page contact - en haut du formulaire', '', ''),
  (41, 'en_US', 'Contact page - at the top of the form', '', ''),
  (42, 'fr_FR', 'Page contact - en bas du formulaire', '', ''),
  (42, 'en_US', 'Contact page - at the bottom of the form', '', ''),
  (43, 'fr_FR', 'Page contact - en bas', '', ''),
  (43, 'en_US', 'Contact page - at the bottom', '', ''),
  (44, 'fr_FR', 'Page contact - feuille de style CSS', '', ''),
  (44, 'en_US', 'Contact page - CSS stylesheet', '', ''),
  (45, 'fr_FR', 'Page contact - après l\'inclusion des javascript', '', ''),
  (45, 'en_US', 'Contact page - after javascript include', '', ''),
  (46, 'fr_FR', 'Page contact - après l\'initialisation du javascript', '', ''),
  (46, 'en_US', 'Contact page - after javascript initialisation', '', ''),
  (47, 'fr_FR', 'Commande terminée - zone principale', '', ''),
  (47, 'en_US', 'Placed order - main area', '', ''),
  (48, 'fr_FR', 'Commande terminée - feuille de style CSS', '', ''),
  (48, 'en_US', 'Placed order - CSS stylesheet', '', ''),
  (49, 'fr_FR', 'Commande terminée - après l\'inclusion des javascript', '', ''),
  (49, 'en_US', 'Placed order - after javascript include', '', ''),
  (50, 'fr_FR', 'Commande terminée - après l\'initialisation du javascript', '', ''),
  (50, 'en_US', 'Placed order - after javascript initialisation', '', ''),
  (51, 'fr_FR', 'Page de recherche - feuille de style CSS', '', ''),
  (51, 'en_US', 'Search page - CSS stylesheet', '', ''),
  (52, 'fr_FR', 'Page de recherche - après l\'inclusion des javascript', '', ''),
  (52, 'en_US', 'Search page - after javascript include', '', ''),
  (53, 'fr_FR', 'Page de recherche - après l\'initialisation du javascript', '', ''),
  (53, 'en_US', 'Search page - after javascript initialisation', '', ''),
  (54, 'fr_FR', 'Création de compte - en haut', '', ''),
  (54, 'en_US', 'Register - at the top', '', ''),
  (55, 'fr_FR', 'Création de compte - en haut du formulaire', '', ''),
  (55, 'en_US', 'Register - at the top of the form', '', ''),
  (56, 'fr_FR', 'Création de compte - en bas du formulaire', '', ''),
  (56, 'en_US', 'Register - at the bottom of the form', '', ''),
  (57, 'fr_FR', 'Création de compte - en bas', '', ''),
  (57, 'en_US', 'Register - at the bottom', '', ''),
  (58, 'fr_FR', 'Création de compte - feuille de style CSS', '', ''),
  (58, 'en_US', 'Register - CSS stylesheet', '', ''),
  (59, 'fr_FR', 'Création de compte - après l\'inclusion des javascript', '', ''),
  (59, 'en_US', 'Register - after javascript include', '', ''),
  (60, 'fr_FR', 'Création de compte - après l\'initialisation du javascript', '', ''),
  (60, 'en_US', 'Register - after javascript initialisation', '', ''),
  (61, 'fr_FR', 'Mot de passe perdu - en haut', '', ''),
  (61, 'en_US', 'Lost password - at the top', '', ''),
  (62, 'fr_FR', 'Mot de passe perdu - en haut du formulaire', '', ''),
  (62, 'en_US', 'Lost password - at the top of the form', '', ''),
  (63, 'fr_FR', 'Mot de passe perdu - en bas du formulaire', '', ''),
  (63, 'en_US', 'Lost password - at the bottom of the form', '', ''),
  (64, 'fr_FR', 'Mot de passe perdu - en bas', '', ''),
  (64, 'en_US', 'Lost password - at the bottom', '', ''),
  (65, 'fr_FR', 'Mot de passe perdu - feuille de style CSS', '', ''),
  (65, 'en_US', 'Lost password - CSS stylesheet', '', ''),
  (66, 'fr_FR', 'Mot de passe perdu - après l\'inclusion des javascript', '', ''),
  (66, 'en_US', 'Lost password - after javascript include', '', ''),
  (67, 'fr_FR', 'Mot de passe perdu - initialisation du javascript', '', ''),
  (67, 'en_US', 'Lost password - javascript initialization', '', ''),
  (68, 'fr_FR', 'Page du choix du langage - en haut', '', ''),
  (68, 'en_US', 'language selection page - at the top', '', ''),
  (69, 'fr_FR', 'Page du choix du langage - en bas', '', ''),
  (69, 'en_US', 'language selection page - at the bottom', '', ''),
  (70, 'fr_FR', 'Page du choix du langage - feuille de style CSS', '', ''),
  (70, 'en_US', 'language selection page - CSS stylesheet', '', ''),
  (71, 'fr_FR', 'Page du choix du langage - après l\'inclusion des javascript', '', ''),
  (71, 'en_US', 'language selection page - after javascript include', '', ''),
  (72, 'fr_FR', 'Page du choix du langage - après l\'initialisation du javascript', '', ''),
  (72, 'en_US', 'language selection page - after javascript initialisation', '', ''),
  (73, 'fr_FR', 'Page contact - en cas de succès', '', ''),
  (73, 'en_US', 'Contact page - if successful response', '', ''),
  (74, 'fr_FR', 'Page newletter - en haut', '', ''),
  (74, 'en_US', 'Newsletter page - at the top', '', ''),
  (75, 'fr_FR', 'Page newletter - en bas', '', ''),
  (75, 'en_US', 'Newsletter page - at the bottom', '', ''),
  (76, 'fr_FR', 'Page newletter - feuille de style CSS', '', ''),
  (76, 'en_US', 'Newsletter page - CSS stylesheet', '', ''),
  (77, 'fr_FR', 'Page newletter - après l\'inclusion des javascript', '', ''),
  (77, 'en_US', 'Newsletter page - after javascript include', '', ''),
  (78, 'fr_FR', 'Page newletter - après l\'initialisation du javascript', '', ''),
  (78, 'en_US', 'Newsletter page - after javascript initialisation', '', ''),
  (79, 'fr_FR', 'Echec du paiement - feuille de style CSS', '', ''),
  (79, 'en_US', 'Payment failed - CSS stylesheet', '', ''),
  (80, 'fr_FR', 'Echec du paiement - après l\'inclusion des javascript', '', ''),
  (80, 'en_US', 'Payment failed - after javascript include', '', ''),
  (81, 'fr_FR', 'Echec du paiement - initialisation du javascript', '', ''),
  (81, 'en_US', 'Payment failed - javascript initialization', '', ''),
  (82, 'fr_FR', 'Page de contenu - en haut', '', ''),
  (82, 'en_US', 'Content page - at the top', '', ''),
  (83, 'fr_FR', 'Page de contenu - en haut de la zone principal', '', ''),
  (83, 'en_US', 'Content page - at the top of the main area', '', ''),
  (84, 'fr_FR', 'Page de contenu - en bas de la zone principal', '', ''),
  (84, 'en_US', 'Content page - at the bottom of the main area', '', ''),
  (85, 'fr_FR', 'Page de contenu - en bas', '', ''),
  (85, 'en_US', 'Content page - at the bottom', '', ''),
  (86, 'fr_FR', 'Page de contenu - feuille de style CSS', '', ''),
  (86, 'en_US', 'Content page - CSS stylesheet', '', ''),
  (87, 'fr_FR', 'Page de contenu - après l\'inclusion des javascript', '', ''),
  (87, 'en_US', 'Content page - after javascript include', '', ''),
  (88, 'fr_FR', 'Page de contenu - après l\'initialisation du javascript', '', ''),
  (88, 'en_US', 'Content page - after javascript initialisation', '', ''),
  (89, 'fr_FR', 'Structure HTML - après l\'ouverture de la balise head', '', ''),
  (89, 'en_US', 'HTML layout - after the opening of the head tag', '', ''),
  (90, 'fr_FR', 'Structure HTML - feuille de style CSS', '', ''),
  (90, 'en_US', 'HTML layout - CSS stylesheet', '', ''),
  (91, 'fr_FR', 'Structure HTML - avant la fin de la balise head', '', ''),
  (91, 'en_US', 'HTML layout - before the end of the head tag', '', ''),
  (92, 'fr_FR', 'Structure HTML - après l\'ouverture de la balise body', '', ''),
  (92, 'en_US', 'HTML layout - after the opening of the body tag', '', ''),
  (93, 'fr_FR', 'Structure HTML - en haut du header', '', ''),
  (93, 'en_US', 'HTML layout - at the top of the header', '', ''),
  (94, 'fr_FR', 'Structure HTML - navigation secondaire', '', ''),
  (94, 'en_US', 'HTML layout - secondary navigation', '', ''),
  (95, 'fr_FR', 'Structure HTML - navigation principale', '', ''),
  (95, 'en_US', 'HTML layout - primary navigation', '', ''),
  (96, 'fr_FR', 'Structure HTML - en bas du header', '', ''),
  (96, 'en_US', 'HTML layout - at the bottom of the header', '', ''),
  (97, 'fr_FR', 'Structure HTML - au dessus de la zone de contenu principale', '', ''),
  (97, 'en_US', 'HTML layout - before the main content area', '', ''),
  (98, 'fr_FR', 'Structure HTML - en dessous de la zone de contenu principale', '', ''),
  (98, 'en_US', 'HTML layout - after the main content area', '', ''),
  (99, 'fr_FR', 'Structure HTML - en haut du pied de page', '', ''),
  (99, 'en_US', 'HTML layout - at the top of the footer', '', ''),
  (100, 'fr_FR', 'Structure HTML - corps du pied de page', '', ''),
  (100, 'en_US', 'HTML layout - footer body', '', ''),
  (101, 'fr_FR', 'Structure HTML - en bas du pied de page', '', ''),
  (101, 'en_US', 'HTML layout - bottom of the footer', '', ''),
  (102, 'fr_FR', 'Structure HTML - après l\'inclusion des javascript', '', ''),
  (102, 'en_US', 'HTML layout - after javascript include', '', ''),
  (103, 'fr_FR', 'Structure HTML - initialisation du javascript', '', ''),
  (103, 'en_US', 'HTML layout - javascript initialization', '', ''),
  (104, 'fr_FR', 'Structure HTML - avant la fin de la balise body', '', ''),
  (104, 'en_US', 'HTML layout - before the end body tag', '', ''),
  (105, 'fr_FR', 'Page introuvable - zone de contenu', '', ''),
  (105, 'en_US', 'Page 404 - content area', '', ''),
  (106, 'fr_FR', 'Page introuvable - feuille de style CSS', '', ''),
  (106, 'en_US', 'Page 404 - CSS stylesheet', '', ''),
  (107, 'fr_FR', 'Page introuvable - après l\'inclusion des javascript', '', ''),
  (107, 'en_US', 'Page 404 - after javascript include', '', ''),
  (108, 'fr_FR', 'Page introuvable - après l\'initialisation du javascript', '', ''),
  (108, 'en_US', 'Page 404 - after javascript initialisation', '', ''),
  (109, 'fr_FR', 'Choix du transporteur - en haut', '', ''),
  (109, 'en_US', 'Delivery choice - at the top', '', ''),
  (110, 'fr_FR', 'Choix du transporteur - en haut du formulaire', '', ''),
  (110, 'en_US', 'Delivery choice - at the top of the form', '', ''),
  (111, 'fr_FR', 'Choix du transporteur - en bas du formulaire', '', ''),
  (111, 'en_US', 'Delivery choice - at the bottom of the form', '', ''),
  (112, 'fr_FR', 'Choix du transporteur - en bas', '', ''),
  (112, 'en_US', 'Delivery choice - at the bottom', '', ''),
  (113, 'fr_FR', 'Choix du transporteur - après l\'initialisation du javascript', '', ''),
  (113, 'en_US', 'Delivery choice - after javascript initialisation', '', ''),
  (114, 'fr_FR', 'Choix du transporteur - feuille de style CSS', '', ''),
  (114, 'en_US', 'Delivery choice - CSS stylesheet', '', ''),
  (115, 'fr_FR', 'Choix du transporteur - après l\'inclusion des javascript', '', ''),
  (115, 'en_US', 'Delivery choice - after javascript include', '', ''),
  (116, 'fr_FR', 'Création adresse - en haut', '', ''),
  (116, 'en_US', 'Address creation - at the top', '', ''),
  (117, 'fr_FR', 'Création adresse - en haut du formulaire', '', ''),
  (117, 'en_US', 'Address creation - at the top of the form', '', ''),
  (118, 'fr_FR', 'Création adresse - en bas du formulaire', '', ''),
  (118, 'en_US', 'Address creation - at the bottom of the form', '', ''),
  (119, 'fr_FR', 'Création adresse - en bas', '', ''),
  (119, 'en_US', 'Address creation - at the bottom', '', ''),
  (120, 'fr_FR', 'Création adresse - feuille de style CSS', '', ''),
  (120, 'en_US', 'Address creation - CSS stylesheet', '', ''),
  (121, 'fr_FR', 'Création adresse - après l\'inclusion des javascript', '', ''),
  (121, 'en_US', 'Address creation - after javascript include', '', ''),
  (122, 'fr_FR', 'Création adresse - après l\'initialisation du javascript', '', ''),
  (122, 'en_US', 'Address creation - after javascript initialisation', '', ''),
  (123, 'fr_FR', 'Page dossier - en haut', '', ''),
  (123, 'en_US', 'Folder page - at the top', '', ''),
  (124, 'fr_FR', 'Page dossier - en haut de la zone principal', '', ''),
  (124, 'en_US', 'Folder page - at the top of the main area', '', ''),
  (125, 'fr_FR', 'Page dossier - en bas de la zone principal', '', ''),
  (125, 'en_US', 'Folder page - at the bottom of the main area', '', ''),
  (126, 'fr_FR', 'Page dossier - en bas', '', ''),
  (126, 'en_US', 'Folder page - at the bottom', '', ''),
  (127, 'fr_FR', 'Page dossier - feuille de style CSS', '', ''),
  (127, 'en_US', 'Folder page - CSS stylesheet', '', ''),
  (128, 'fr_FR', 'Page dossier - après l\'inclusion des javascript', '', ''),
  (128, 'en_US', 'Folder page - after javascript include', '', ''),
  (129, 'fr_FR', 'Page dossier - après l\'initialisation du javascript', '', ''),
  (129, 'en_US', 'Folder page - after javascript initialisation', '', ''),
  (130, 'fr_FR', 'Echec de la commande - en haut', '', ''),
  (130, 'en_US', 'Order failed - at the top', '', ''),
  (131, 'fr_FR', 'Echec de la commande - en bas', '', ''),
  (131, 'en_US', 'Order failed - at the bottom', '', ''),
  (132, 'fr_FR', 'Echec de la commande - feuille de style CSS', '', ''),
  (132, 'en_US', 'Order failed - CSS stylesheet', '', ''),
  (133, 'fr_FR', 'Echec de la commande - après l\'inclusion des javascript', '', ''),
  (133, 'en_US', 'Order failed - after javascript include', '', ''),
  (134, 'fr_FR', 'Echec de la commande - après l\'initialisation du javascript', '', ''),
  (134, 'en_US', 'Order failed - after javascript initialisation', '', ''),
  (135, 'fr_FR', 'Page catégorie - en haut', '', ''),
  (135, 'en_US', 'Category page - at the top', '', ''),
  (136, 'fr_FR', 'Page catégorie - en haut de la zone principal', '', ''),
  (136, 'en_US', 'Category page - at the top of the main area', '', ''),
  (137, 'fr_FR', 'Page catégorie - en bas de la zone principal', '', ''),
  (137, 'en_US', 'Category page - at the bottom of the main area', '', ''),
  (138, 'fr_FR', 'Page catégorie - en bas', '', ''),
  (138, 'en_US', 'Category page - at the bottom', '', ''),
  (139, 'fr_FR', 'Page catégorie - feuille de style CSS', '', ''),
  (139, 'en_US', 'Category page - CSS stylesheet', '', ''),
  (140, 'fr_FR', 'Page catégorie - après l\'inclusion des javascript', '', ''),
  (140, 'en_US', 'Category page - after javascript include', '', ''),
  (141, 'fr_FR', 'Page catégorie - après l\'initialisation du javascript', '', ''),
  (141, 'en_US', 'Category page - after javascript initialisation', '', ''),
  (142, 'fr_FR', 'Modification adresse - en haut', '', ''),
  (142, 'en_US', 'Address update - at the top', '', ''),
  (143, 'fr_FR', 'Modification adresse - en haut du formulaire', '', ''),
  (143, 'en_US', 'Address update - at the top of the form', '', ''),
  (144, 'fr_FR', 'Modification adresse - en bas du formulaire', '', ''),
  (144, 'en_US', 'Address update - at the bottom of the form', '', ''),
  (145, 'fr_FR', 'Modification adresse - en bas', '', ''),
  (145, 'en_US', 'Address update - at the bottom', '', ''),
  (146, 'fr_FR', 'Modification adresse - feuille de style CSS', '', ''),
  (146, 'en_US', 'Address update - CSS stylesheet', '', ''),
  (147, 'fr_FR', 'Modification adresse - après l\'inclusion des javascript', '', ''),
  (147, 'en_US', 'Address update - after javascript include', '', ''),
  (148, 'fr_FR', 'Modification adresse - après l\'initialisation du javascript', '', ''),
  (148, 'en_US', 'Address update - after javascript initialisation', '', ''),
  (149, 'fr_FR', 'Page d\'accueil - zone principale', '', ''),
  (149, 'en_US', 'Home page - main area', '', ''),
  (150, 'fr_FR', 'Page d\'accueil - feuille de style CSS', '', ''),
  (150, 'en_US', 'Home page - CSS stylesheet', '', ''),
  (151, 'fr_FR', 'Page d\'accueil - après l\'inclusion des javascript', '', ''),
  (151, 'en_US', 'Home page - after javascript include', '', ''),
  (152, 'fr_FR', 'Page d\'accueil - après l\'initialisation du javascript', '', ''),
  (152, 'en_US', 'Home page - after javascript initialisation', '', ''),
  (153, 'fr_FR', 'Changement de mot de passe - en haut', '', ''),
  (153, 'en_US', 'Change password - at the top', '', ''),
  (154, 'fr_FR', 'Changement de mot de passe - en bas', '', ''),
  (154, 'en_US', 'Change password - at the bottom', '', ''),
  (155, 'fr_FR', 'Changement de mot de passe - feuille de style CSS', '', ''),
  (155, 'en_US', 'Change password - CSS stylesheet', '', ''),
  (156, 'fr_FR', 'Changement de mot de passe - après l\'inclusion des javascript', '', ''),
  (156, 'en_US', 'Change password - after javascript include', '', ''),
  (157, 'fr_FR', 'Changement de mot de passe - après l\'initialisation du javascript', '', ''),
  (157, 'en_US', 'Change password - after javascript initialisation', '', ''),
  (158, 'fr_FR', 'Page produit - en haut', '', ''),
  (158, 'en_US', 'Product page - at the top', '', ''),
  (159, 'fr_FR', 'Page produit - gallerie photos', '', ''),
  (159, 'en_US', 'Product page - photo gallery', '', ''),
  (160, 'fr_FR', 'Page produit - en haut de la zone détail', '', ''),
  (160, 'en_US', 'Product page - at the top of the detail', '', ''),
  (161, 'fr_FR', 'Page produit - en dessous de la zone de détail', '', ''),
  (161, 'en_US', 'Product page - at the bottom of the detail area', '', ''),
  (162, 'fr_FR', 'Page produit - informations additionnelles', '', ''),
  (162, 'en_US', 'Product page - additional information', '', ''),
  (163, 'fr_FR', 'Page produit - en bas', '', ''),
  (163, 'en_US', 'Product page - at the bottom', '', ''),
  (164, 'fr_FR', 'Page produit - feuille de style CSS', '', ''),
  (164, 'en_US', 'Product page - CSS stylesheet', '', ''),
  (165, 'fr_FR', 'Page produit - après l\'inclusion des javascript', '', ''),
  (165, 'en_US', 'Product page - after javascript include', '', ''),
  (166, 'fr_FR', 'Page produit - après l\'initialisation du javascript', '', ''),
  (166, 'en_US', 'Product page - after javascript initialisation', '', ''),
  (167, 'fr_FR', 'Compte client - en haut', '', ''),
  (167, 'en_US', 'customer account - at the top', '', ''),
  (168, 'fr_FR', 'Compte client - en bas', '', ''),
  (168, 'en_US', 'customer account - at the bottom', '', ''),
  (169, 'fr_FR', 'Compte client - feuille de style CSS', '', ''),
  (169, 'en_US', 'customer account - CSS stylesheet', '', ''),
  (170, 'fr_FR', 'Compte client - après l\'inclusion des javascript', '', ''),
  (170, 'en_US', 'customer account - after javascript include', '', ''),
  (171, 'fr_FR', 'Compte client - après l\'initialisation du javascript', '', ''),
  (171, 'en_US', 'customer account - after javascript initialisation', '', ''),
  (172, 'fr_FR', 'Tous les produits - en haut', '', ''),
  (172, 'en_US', 'All Products - at the top', '', ''),
  (173, 'fr_FR', 'Tous les produits - en bas', '', ''),
  (173, 'en_US', 'All Products - at the bottom', '', ''),
  (174, 'fr_FR', 'Tous les produits - feuille de style CSS', '', ''),
  (174, 'en_US', 'All Products - CSS stylesheet', '', ''),
  (175, 'fr_FR', 'Tous les produits - après l\'inclusion des javascript', '', ''),
  (175, 'en_US', 'All Products - after javascript include', '', ''),
  (176, 'fr_FR', 'Tous les produits - après l\'initialisation du javascript', '', ''),
  (176, 'en_US', 'All Products - after javascript initialisation', '', ''),
  (177, 'fr_FR', 'Boucle produit - en haut', '', ''),
  (177, 'en_US', 'Product loop - at the top', '', ''),
  (178, 'fr_FR', 'Boucle produit - en bas', '', ''),
  (178, 'en_US', 'Product loop - at the bottom', '', ''),
  (179, 'fr_FR', 'Page catégorie - en haut de la sidebar', '', ''),
  (179, 'en_US', 'Category page - at the top of the sidebar', '', ''),
  (180, 'fr_FR', 'Page catégorie - le corps de la sidebar', '', ''),
  (180, 'en_US', 'Category page - the body of the sidebar', '', ''),
  (181, 'fr_FR', 'Page catégorie - en bas de la sidebar', '', ''),
  (181, 'en_US', 'Category page - at the bottom of the sidebar', '', ''),
  (182, 'fr_FR', 'Page de contenu - en haut de la sidebar', '', ''),
  (182, 'en_US', 'Content page - at the top of the sidebar', '', ''),
  (183, 'fr_FR', 'Page de contenu - le corps de la sidebar', '', ''),
  (183, 'en_US', 'Content page - the body of the sidebar', '', ''),
  (184, 'fr_FR', 'Page de contenu - en bas de la sidebar', '', ''),
  (184, 'en_US', 'Content page - at the bottom of the sidebar', '', ''),
  (185, 'fr_FR', 'Choix du transporteur - zone supplémentaire', '', ''),
  (185, 'en_US', 'Delivery choice - extra area', '', ''),
  (186, 'fr_FR', 'Choix du transporteur - javascript', '', ''),
  (186, 'en_US', 'Delivery choice - javascript', '', ''),
  (1000, 'en_US', 'Category - content', '', ''),
  (1000, 'fr_FR', 'Catégorie - contenu', '', ''),
  (1001, 'en_US', 'Content - content', '', ''),
  (1001, 'fr_FR', 'Contenu - contenu', '', ''),
  (1002, 'en_US', 'Folder - content', '', ''),
  (1002, 'fr_FR', 'Dossier - contenu', '', ''),
  (1003, 'en_US', 'Order - content', '', ''),
  (1003, 'fr_FR', 'Commande - contenu', '', ''),
  (1004, 'en_US', 'Product - content', '', ''),
  (1004, 'fr_FR', 'Produit - contenu', '', ''),
  (1005, 'en_US', 'Features value - table header', '', ''),
  (1005, 'fr_FR', 'Valeur de caractéristiques - colonne tableau', '', ''),
  (1006, 'en_US', 'Features value - table row', '', ''),
  (1006, 'fr_FR', 'Valeur de caractéristiques - ligne tableau', '', ''),
  (1007, 'en_US', 'Feature - Value create form', '', ''),
  (1007, 'fr_FR', 'Caractéristique - Formulaire de création de valeur', '', ''),
  (1008, 'en_US', 'Feature - Edit JavaScript', '', ''),
  (1008, 'fr_FR', 'Caractéristique - JavaScript modification', '', ''),
  (1009, 'en_US', 'Product - Edit JavaScript', '', ''),
  (1009, 'fr_FR', 'Produit - JavaScript modification', '', ''),
  (1010, 'en_US', 'Coupon - create JavaScript', '', ''),
  (1010, 'fr_FR', 'Code promo - JavaScript création', '', ''),
  (1011, 'en_US', 'Taxes - update form', '', ''),
  (1011, 'fr_FR', 'Taxes - formulaire de modification', '', ''),
  (1012, 'en_US', 'tax rule - Edit JavaScript', '', ''),
  (1012, 'fr_FR', 'Règle de taxe - JavaScript modification', '', ''),
  (1013, 'en_US', 'Tools - at the top', '', ''),
  (1013, 'fr_FR', 'Outils - en haut', '', ''),
  (1014, 'en_US', 'Tools - at the top of the column', '', ''),
  (1014, 'fr_FR', 'Outils - en haut de la colonne', '', ''),
  (1015, 'en_US', 'Tools - at the bottom of column 1', '', ''),
  (1015, 'fr_FR', 'Outils - en bas de la colonne 1', '', ''),
  (1016, 'en_US', 'Tools - bottom', '', ''),
  (1016, 'fr_FR', 'Outils - bas', '', ''),
  (1017, 'en_US', 'Tools - JavaScript', '', ''),
  (1017, 'fr_FR', 'Outils - JavaScript', '', ''),
  (1018, 'en_US', 'Messages - at the top', '', ''),
  (1018, 'fr_FR', 'Messages - en haut', '', ''),
  (1019, 'en_US', 'Messages - table header', '', ''),
  (1019, 'fr_FR', 'Messages - colonne tableau', '', ''),
  (1020, 'en_US', 'Messages - table row', '', ''),
  (1020, 'fr_FR', 'Messages - ligne tableau', '', ''),
  (1021, 'en_US', 'Messages - bottom', '', ''),
  (1021, 'fr_FR', 'Messages - bas', '', ''),
  (1022, 'en_US', 'Message - create form', '', ''),
  (1022, 'fr_FR', 'Message - formulaire de création', '', ''),
  (1023, 'en_US', 'Message - delete form', '', ''),
  (1023, 'fr_FR', 'Message - formulaire de suppression', '', ''),
  (1024, 'en_US', 'Messages - JavaScript', '', ''),
  (1024, 'fr_FR', 'Messages - JavaScript', '', ''),
  (1025, 'en_US', 'Taxes rules - at the top', '', ''),
  (1025, 'fr_FR', 'Règles de taxes - en haut', '', ''),
  (1026, 'en_US', 'Taxes rules - bottom', '', ''),
  (1026, 'fr_FR', 'Règles de taxes - bas', '', ''),
  (1027, 'en_US', 'Tax - create form', '', ''),
  (1027, 'fr_FR', 'Taxe - formulaire de création', '', ''),
  (1028, 'en_US', 'Tax - delete form', '', ''),
  (1028, 'fr_FR', 'Taxe - formulaire de suppression', '', ''),
  (1029, 'en_US', 'tax rule - create form', '', ''),
  (1029, 'fr_FR', 'Règle de taxe - formulaire de création', '', ''),
  (1030, 'en_US', 'tax rule - delete form', '', ''),
  (1030, 'fr_FR', 'Règle de taxe - formulaire de suppression', '', ''),
  (1031, 'en_US', 'Taxes rules - JavaScript', '', ''),
  (1031, 'fr_FR', 'Règles de taxes - JavaScript', '', ''),
  (1032, 'en_US', 'Exports - at the top', '', ''),
  (1032, 'fr_FR', 'Exports - en haut', '', ''),
  (1033, 'en_US', 'Exports - at the bottom of a category', '', ''),
  (1033, 'fr_FR', 'Exports - en bas d''une catégorie', '', ''),
  (1034, 'en_US', 'Exports - at the bottom of column 1', '', ''),
  (1034, 'fr_FR', 'Exports - en bas de la colonne 1', '', ''),
  (1035, 'en_US', 'Exports - JavaScript', '', ''),
  (1035, 'fr_FR', 'Exports - JavaScript', '', ''),
  (1036, 'en_US', 'Export - JavaScript', '', ''),
  (1036, 'fr_FR', 'Export - JavaScript', '', ''),
  (1037, 'en_US', 'Product - folders table header', '', ''),
  (1037, 'fr_FR', 'Produit - colonne tableau dossiers', '', ''),
  (1038, 'en_US', 'Product - folders table row', '', ''),
  (1038, 'fr_FR', 'Produit - ligne tableau dossiers', '', ''),
  (1039, 'en_US', 'Product - details pricing form', '', ''),
  (1039, 'fr_FR', 'Produit - Formulaire détails des prix', '', ''),
  (1040, 'en_US', 'Product - stock edit form', '', ''),
  (1040, 'fr_FR', 'Produit - formulaire de modification du stock', '', ''),
  (1041, 'en_US', 'Product - details promotion form', '', ''),
  (1041, 'fr_FR', 'Produit - Formulaire détail promotion', '', ''),
  (1042, 'en_US', 'Product - before combinations', '', ''),
  (1042, 'fr_FR', 'Produit - avant les déclinaisons', '', ''),
  (1043, 'en_US', 'Product - combinations list caption', '', ''),
  (1043, 'fr_FR', 'Produit - légende liste des déclinaisons', '', ''),
  (1044, 'en_US', 'Product - after combinations', '', ''),
  (1044, 'fr_FR', 'Produit - après les déclinaisons', '', ''),
  (1045, 'en_US', 'Product - combination delete form', '', ''),
  (1045, 'fr_FR', 'Produit - formulaire de suppression de combinaison', '', ''),
  (1046, 'en_US', 'Modules - table header', '', ''),
  (1046, 'fr_FR', 'Modules - colonne tableau', '', ''),
  (1047, 'en_US', 'Modules - table row', '', ''),
  (1047, 'fr_FR', 'Modules - ligne tableau', '', ''),
  (1048, 'en_US', 'Currency - Edit JavaScript', '', ''),
  (1048, 'fr_FR', 'Devise - JavaScript modification', '', ''),
  (1049, 'en_US', 'Category - contents table header', '', ''),
  (1049, 'fr_FR', 'Catégorie - colonne tableau contenus', '', ''),
  (1050, 'en_US', 'Category - contents table row', '', ''),
  (1050, 'fr_FR', 'Catégorie - ligne tableau contenus', '', ''),
  (1051, 'en_US', 'Category - Edit JavaScript', '', ''),
  (1051, 'fr_FR', 'Catégorie - JavaScript modification', '', ''),
  (1052, 'en_US', 'Document - Edit JavaScript', '', ''),
  (1052, 'fr_FR', 'Document - JavaScript modification', '', ''),
  (1053, 'en_US', 'Customer - at the top', '', ''),
  (1053, 'fr_FR', 'Client - en haut', '', ''),
  (1054, 'en_US', 'Customers - caption', '', ''),
  (1054, 'fr_FR', 'Clients - légende', '', ''),
  (1055, 'en_US', 'Customers - header', '', ''),
  (1055, 'fr_FR', 'Clients - en-tête', '', ''),
  (1056, 'en_US', 'Customers - row', '', ''),
  (1056, 'fr_FR', 'Clients - ligne', '', ''),
  (1057, 'en_US', 'Customer - bottom', '', ''),
  (1057, 'fr_FR', 'Client - bas', '', ''),
  (1058, 'en_US', 'Customer - create form', '', ''),
  (1058, 'fr_FR', 'Client - formulaire de création', '', ''),
  (1059, 'en_US', 'Customer - delete form', '', ''),
  (1059, 'fr_FR', 'Client - formulaire de suppression', '', ''),
  (1060, 'en_US', 'Customers - JavaScript', '', ''),
  (1060, 'fr_FR', 'Clients - JavaScript', '', ''),
  (1061, 'en_US', 'Product - contents table header', '', ''),
  (1061, 'fr_FR', 'Produit - colonne tableau contenus', '', ''),
  (1062, 'en_US', 'Product - contents table row', '', ''),
  (1062, 'fr_FR', 'Produit - ligne tableau contenus', '', ''),
  (1063, 'en_US', 'Product - accessories table header', '', ''),
  (1063, 'fr_FR', 'Produit - colonne tableau accessoires', '', ''),
  (1064, 'en_US', 'Product - accessories table row', '', ''),
  (1064, 'fr_FR', 'Produit - ligne tableau accessoires', '', ''),
  (1065, 'en_US', 'Product - categories table header', '', ''),
  (1065, 'fr_FR', 'Produit - colonne tableau catégories', '', ''),
  (1066, 'en_US', 'Product - categories table row', '', ''),
  (1066, 'fr_FR', 'Produit - ligne tableau catégories', '', ''),
  (1067, 'en_US', 'Product - attributes table header', '', ''),
  (1067, 'fr_FR', 'Produit - colonne tableau attributs', '', ''),
  (1068, 'en_US', 'Product - attributes table row', '', ''),
  (1068, 'fr_FR', 'Produit - ligne tableau attributs', '', ''),
  (1069, 'en_US', 'Product - features-table-header', '', ''),
  (1069, 'fr_FR', 'Produit - colonne tableau caractéristiques', '', ''),
  (1070, 'en_US', 'Product - features table row', '', ''),
  (1070, 'fr_FR', 'Produit - ligne tableau caractéristiques', '', ''),
  (1071, 'en_US', 'Template - attributes table header', '', ''),
  (1071, 'fr_FR', 'Gabarit - colonne tableau attributs', '', ''),
  (1072, 'en_US', 'Template - attributes table row', '', ''),
  (1072, 'fr_FR', 'Gabarit - ligne tableau attributs', '', ''),
  (1073, 'en_US', 'Template - features-table-header', '', ''),
  (1073, 'fr_FR', 'Gabarit - colonne tableau caractéristiques', '', ''),
  (1074, 'en_US', 'Template - features table row', '', ''),
  (1074, 'fr_FR', 'Gabarit - ligne tableau caractéristiques', '', ''),
  (1075, 'en_US', 'Templates - at the top', '', ''),
  (1075, 'fr_FR', 'Gabarits - en haut', '', ''),
  (1076, 'en_US', 'Templates - table header', '', ''),
  (1076, 'fr_FR', 'Gabarits - colonne tableau', '', ''),
  (1077, 'en_US', 'Templates - table row', '', ''),
  (1077, 'fr_FR', 'Gabarits - ligne tableau', '', ''),
  (1078, 'en_US', 'Templates - bottom', '', ''),
  (1078, 'fr_FR', 'Gabarits - bas', '', ''),
  (1079, 'en_US', 'Template - create form', '', ''),
  (1079, 'fr_FR', 'Gabarit - formulaire de création', '', ''),
  (1080, 'en_US', 'Template - delete form', '', ''),
  (1080, 'fr_FR', 'Gabarit - formulaire de suppression', '', ''),
  (1081, 'en_US', 'Templates - JavaScript', '', ''),
  (1081, 'fr_FR', 'Gabarits - JavaScript', '', ''),
  (1082, 'en_US', 'Configuration - at the top', '', ''),
  (1082, 'fr_FR', 'Configuration - en haut', '', ''),
  (1083, 'en_US', 'Configuration - at the top of the catalog area', '', ''),
  (1083, 'fr_FR', 'Configuration - en haut de la zone catalogue', '', ''),
  (1084, 'en_US', 'Configuration - at the bottom of the catalog', '', ''),
  (1084, 'fr_FR', 'Configuration - en bas du catlogue', '', ''),
  (1085, 'en_US', 'Configuration - at the top of the shipping area', '', ''),
  (1085, 'fr_FR', 'Configuration - en haut de la zone livraison', '', ''),
  (1086, 'en_US', 'Configuration - at the bottom of the shipping area', '', ''),
  (1086, 'fr_FR', 'Configuration - en bas de la zone livraison', '', ''),
  (1087, 'en_US', 'Configuration - at the top of the system area', '', ''),
  (1087, 'fr_FR', 'Configuration - en haut de la zone système', '', ''),
  (1088, 'en_US', 'Configuration - at the bottom of the system area', '', ''),
  (1088, 'fr_FR', 'Configuration - en bas de la zone système', '', ''),
  (1089, 'en_US', 'Configuration - bottom', '', ''),
  (1089, 'fr_FR', 'Configuration - bas', '', ''),
  (1090, 'en_US', 'Configuration - JavaScript', '', ''),
  (1090, 'fr_FR', 'Configuration - JavaScript', '', ''),
  (1091, 'en_US', 'Dashboard - at the top', '', ''),
  (1091, 'fr_FR', 'Tableau de bord - en haut', '', ''),
  (1092, 'en_US', 'Dashboard - middle', '', ''),
  (1092, 'fr_FR', 'Tableau de bord - au milieu', '', ''),
  (1093, 'en_US', 'Dashboard - bottom', '', ''),
  (1093, 'fr_FR', 'Tableau de bord - bas', '', ''),
  (1094, 'en_US', 'Orders - at the top', '', ''),
  (1094, 'fr_FR', 'Commandes - en haut', '', ''),
  (1095, 'en_US', 'Orders - table header', '', ''),
  (1095, 'fr_FR', 'Commandes - colonne tableau', '', ''),
  (1096, 'en_US', 'Orders - table row', '', ''),
  (1096, 'fr_FR', 'Commandes - ligne tableau', '', ''),
  (1097, 'en_US', 'Orders - bottom', '', ''),
  (1097, 'fr_FR', 'Commandes - bas', '', ''),
  (1098, 'en_US', 'Orders - JavaScript', '', ''),
  (1098, 'fr_FR', 'Commandes - JavaScript', '', ''),
  (1099, 'en_US', 'Delivery zone - at the top', '', ''),
  (1099, 'fr_FR', 'Zone de livraison - en haut', '', ''),
  (1100, 'en_US', 'Delivery zone - table header', '', ''),
  (1100, 'fr_FR', 'Zone de livraison - colonne tableau', '', ''),
  (1101, 'en_US', 'Delivery zone - table row', '', ''),
  (1101, 'fr_FR', 'Zone de livraison - ligne tableau', '', ''),
  (1102, 'en_US', 'Delivery zone - bottom', '', ''),
  (1102, 'fr_FR', 'Zone de livraison - bas', '', ''),
  (1103, 'en_US', 'Delivery zone - JavaScript', '', ''),
  (1103, 'fr_FR', 'Zone de livraison - JavaScript', '', ''),
  (1104, 'en_US', 'Content - Edit JavaScript', '', ''),
  (1104, 'fr_FR', 'Contenu - JavaScript modification', '', ''),
  (1105, 'en_US', 'Home - at the top', '', ''),
  (1105, 'fr_FR', 'Accueil - en haut', '', ''),
  (1106, 'en_US', 'Home - bottom', '', ''),
  (1106, 'fr_FR', 'Accueil - bas', '', ''),
  (1107, 'en_US', 'Home - JavaScript', '', ''),
  (1107, 'fr_FR', 'Accueil - JavaScript', '', ''),
  (1108, 'en_US', 'Modules - at the top', '', ''),
  (1108, 'fr_FR', 'Modules - en haut', '', ''),
  (1109, 'en_US', 'Modules - bottom', '', ''),
  (1109, 'fr_FR', 'Modules - bas', '', ''),
  (1110, 'en_US', 'Modules - JavaScript', '', ''),
  (1110, 'fr_FR', 'Modules - JavaScript', '', ''),
  (1111, 'en_US', 'Languages - at the top', '', ''),
  (1111, 'fr_FR', 'Langages - en haut', '', ''),
  (1112, 'en_US', 'Languages - bottom', '', ''),
  (1112, 'fr_FR', 'Langages - bas', '', ''),
  (1113, 'en_US', 'Language - create form', '', ''),
  (1113, 'fr_FR', 'Langage - formulaire de création', '', ''),
  (1114, 'en_US', 'Languages - delete form', '', ''),
  (1114, 'fr_FR', 'Langages - formulaire de suppression', '', ''),
  (1115, 'en_US', 'Languages - JavaScript', '', ''),
  (1115, 'fr_FR', 'Langages - JavaScript', '', ''),
  (1116, 'en_US', 'Zone - delete form', '', ''),
  (1116, 'fr_FR', 'Zone - formulaire de suppression', '', ''),
  (1117, 'en_US', 'Delivery zone - Edit JavaScript', '', ''),
  (1117, 'fr_FR', 'Zone de livraison - JavaScript modification', '', ''),
  (1118, 'en_US', 'System - logs JavaScript', '', ''),
  (1118, 'fr_FR', 'Système - JavaScript logs', '', ''),
  (1119, 'en_US', 'Search - at the top', '', ''),
  (1119, 'fr_FR', 'Recherche - en haut', '', ''),
  (1120, 'en_US', 'Search - bottom', '', ''),
  (1120, 'fr_FR', 'Recherche - bas', '', ''),
  (1121, 'en_US', 'Search - JavaScript', '', ''),
  (1121, 'fr_FR', 'Recherche - JavaScript', '', ''),
  (1122, 'en_US', 'Administrators - at the top', '', ''),
  (1122, 'fr_FR', 'Administateurs - en haut', '', ''),
  (1123, 'en_US', 'Administrators - bottom', '', ''),
  (1123, 'fr_FR', 'Administateurs - bas', '', ''),
  (1124, 'en_US', 'Administrator - create form', '', ''),
  (1124, 'fr_FR', 'Administateur - formulaire de création', '', ''),
  (1125, 'en_US', 'Administrator - update form', '', ''),
  (1125, 'fr_FR', 'Administateur - formulaire de modification', '', ''),
  (1126, 'en_US', 'Administrator - delete form', '', ''),
  (1126, 'fr_FR', 'Administateur - formulaire de suppression', '', ''),
  (1127, 'en_US', 'Administrators - JavaScript', '', ''),
  (1127, 'fr_FR', 'Administateurs - JavaScript', '', ''),
  (1128, 'en_US', 'Module hook - Edit JavaScript', '', ''),
  (1128, 'fr_FR', 'Module hook - JavaScript modification', '', ''),
  (1129, 'en_US', 'Shipping configuration - at the top', '', ''),
  (1129, 'fr_FR', 'Configuration du transport - en haut', '', ''),
  (1130, 'en_US', 'Shipping configuration - table header', '', ''),
  (1130, 'fr_FR', 'Configuration du transport - colonne tableau', '', ''),
  (1131, 'en_US', 'Shipping configuration - table row', '', ''),
  (1131, 'fr_FR', 'Configuration du transport - ligne tableau', '', ''),
  (1132, 'en_US', 'Shipping configuration - bottom', '', ''),
  (1132, 'fr_FR', 'Configuration du transport - bas', '', ''),
  (1133, 'en_US', 'Shipping configuration - create form', '', ''),
  (1133, 'fr_FR', 'Configuration du transport - formulaire de création', '', ''),
  (1134, 'en_US', 'Shipping configuration - delete form', '', ''),
  (1134, 'fr_FR', 'Configuration du transport - formulaire de suppression', '', ''),
  (1135, 'en_US', 'Shipping configuration - JavaScript', '', ''),
  (1135, 'fr_FR', 'Configuration du transport - JavaScript', '', ''),
  (1136, 'en_US', 'Features - at the top', '', ''),
  (1136, 'fr_FR', 'Caractéristiques - en haut', '', ''),
  (1137, 'en_US', 'Features - table header', '', ''),
  (1137, 'fr_FR', 'Caractéristiques - colonne tableau', '', ''),
  (1138, 'en_US', 'Features - table row', '', ''),
  (1138, 'fr_FR', 'Caractéristiques - ligne tableau', '', ''),
  (1139, 'en_US', 'Features - bottom', '', ''),
  (1139, 'fr_FR', 'Caractéristiques - bas', '', ''),
  (1140, 'en_US', 'Feature - create form', '', ''),
  (1140, 'fr_FR', 'Caractéristique - formulaire de création', '', ''),
  (1141, 'en_US', 'Feature - delete form', '', ''),
  (1141, 'fr_FR', 'Caractéristique - formulaire de suppression', '', ''),
  (1142, 'en_US', 'Feature - add to all form', '', ''),
  (1142, 'fr_FR', 'Caractéristique - formulaire ajouter à tous', '', ''),
  (1143, 'en_US', 'Feature - remove to all form', '', ''),
  (1143, 'fr_FR', 'Caractéristique - formulaire de suppression multiple', '', ''),
  (1144, 'en_US', 'Features - JavaScript', '', ''),
  (1144, 'fr_FR', 'Caractéristiques - JavaScript', '', ''),
  (1145, 'en_US', 'Module - Edit JavaScript', '', ''),
  (1145, 'fr_FR', 'Module - JavaScript modification', '', ''),
  (1146, 'en_US', 'Module hook - create form', '', ''),
  (1146, 'fr_FR', 'Module hook - formulaire de création', '', ''),
  (1147, 'en_US', 'Module hook - delete form', '', ''),
  (1147, 'fr_FR', 'Module hook - formulaire de suppression', '', ''),
  (1148, 'en_US', 'Module hook - JavaScript', '', ''),
  (1148, 'fr_FR', 'Module hook - JavaScript', '', ''),
  (1149, 'en_US', 'Shipping configuration - Edit', '', ''),
  (1149, 'fr_FR', 'Configuration du transport - Modification', '', ''),
  (1150, 'en_US', 'Shipping configuration - country delete form', '', ''),
  (1150, 'fr_FR', 'Configuration du transport - formulaire de suppression de pays', '', ''),
  (1151, 'en_US', 'Shipping configuration - Edit JavaScript', '', ''),
  (1151, 'fr_FR', 'Configuration du transport - JavaScript modification', '', ''),
  (1152, 'en_US', 'Mailing system - at the top', '', ''),
  (1152, 'fr_FR', 'Envoi des e-mails - en haut', '', ''),
  (1153, 'en_US', 'Mailing system - bottom', '', ''),
  (1153, 'fr_FR', 'Envoi des e-mails - bas', '', ''),
  (1154, 'en_US', 'Mailing system - JavaScript', '', ''),
  (1154, 'fr_FR', 'Envoi des e-mails - JavaScript', '', ''),
  (1155, 'en_US', 'Categories - at the top', '', ''),
  (1155, 'fr_FR', 'Catégories - en haut', '', ''),
  (1156, 'en_US', 'Categories - caption', '', ''),
  (1156, 'fr_FR', 'Catégories - légende', '', ''),
  (1157, 'en_US', 'Categories - header', '', ''),
  (1157, 'fr_FR', 'Catégories - en-tête', '', ''),
  (1158, 'en_US', 'Categories - row', '', ''),
  (1158, 'fr_FR', 'Catégories - ligne', '', ''),
  (1159, 'en_US', 'Products - caption', '', ''),
  (1159, 'fr_FR', 'Produits - légende', '', ''),
  (1160, 'en_US', 'Products - header', '', ''),
  (1160, 'fr_FR', 'Produits - en-tête', '', ''),
  (1161, 'en_US', 'Products - row', '', ''),
  (1161, 'fr_FR', 'Produits - ligne', '', ''),
  (1162, 'en_US', 'Categories - bottom', '', ''),
  (1162, 'fr_FR', 'Catégories - bas', '', ''),
  (1163, 'en_US', 'Categories - at the bottom of the catalog', '', ''),
  (1163, 'fr_FR', 'Catégories - en bas du catalogue', '', ''),
  (1164, 'en_US', 'Category - create form', '', ''),
  (1164, 'fr_FR', 'Catégorie - formulaire de création', '', ''),
  (1165, 'en_US', 'Product - create form', '', ''),
  (1165, 'fr_FR', 'Produit - formulaire de création', '', ''),
  (1166, 'en_US', 'Category - delete form', '', ''),
  (1166, 'fr_FR', 'Catégorie - formulaire de suppression', '', ''),
  (1167, 'en_US', 'Product - delete form', '', ''),
  (1167, 'fr_FR', 'Produit - formulaire de suppression', '', ''),
  (1168, 'en_US', 'Categories - JavaScript', '', ''),
  (1168, 'fr_FR', 'Catégories - JavaScript', '', ''),
  (1169, 'en_US', 'Variables - at the top', '', ''),
  (1169, 'fr_FR', 'Variables - en haut', '', ''),
  (1170, 'en_US', 'Variables - table header', '', ''),
  (1170, 'fr_FR', 'Variables - colonne tableau', '', ''),
  (1171, 'en_US', 'Variables - table row', '', ''),
  (1171, 'fr_FR', 'Variables - ligne tableau', '', ''),
  (1172, 'en_US', 'Variables - bottom', '', ''),
  (1172, 'fr_FR', 'Variables - bas', '', ''),
  (1173, 'en_US', 'Variable - create form', '', ''),
  (1173, 'fr_FR', 'Variable - formulaire de création', '', ''),
  (1174, 'en_US', 'Variable - delete form', '', ''),
  (1174, 'fr_FR', 'Variable - formulaire de suppression', '', ''),
  (1175, 'en_US', 'Variables - JavaScript', '', ''),
  (1175, 'fr_FR', 'Variables - JavaScript', '', ''),
  (1176, 'en_US', 'Order - product list', '', ''),
  (1176, 'fr_FR', 'Commande - liste produit', '', ''),
  (1177, 'en_US', 'Order - Edit JavaScript', '', ''),
  (1177, 'fr_FR', 'Commande - JavaScript modification', '', ''),
  (1178, 'en_US', 'Store Information - JavaScript', '', ''),
  (1178, 'fr_FR', 'Information boutique - JavaScript', '', ''),
  (1179, 'en_US', 'Translations - JavaScript', '', ''),
  (1179, 'fr_FR', 'Traductions - JavaScript', '', ''),
  (1180, 'en_US', 'Folder - at the top', '', ''),
  (1180, 'fr_FR', 'Dossiers - en haut', '', ''),
  (1181, 'en_US', 'Folder - caption', '', ''),
  (1181, 'fr_FR', 'Dossiers - légende', '', ''),
  (1182, 'en_US', 'Folder - header', '', ''),
  (1182, 'fr_FR', 'Dossiers - en-tête', '', ''),
  (1183, 'en_US', 'Folder - row', '', ''),
  (1183, 'fr_FR', 'Dossiers - ligne', '', ''),
  (1184, 'en_US', 'Contents - caption', '', ''),
  (1184, 'fr_FR', 'Contenus - légende', '', ''),
  (1185, 'en_US', 'Contents - header', '', ''),
  (1185, 'fr_FR', 'Contenus - en-tête', '', ''),
  (1186, 'en_US', 'Contents - row', '', ''),
  (1186, 'fr_FR', 'Contenus - ligne', '', ''),
  (1187, 'en_US', 'Folder - bottom', '', ''),
  (1187, 'fr_FR', 'Dossiers - bas', '', ''),
  (1188, 'en_US', 'Folder - create form', '', ''),
  (1188, 'fr_FR', 'Dossier - formulaire de création', '', ''),
  (1189, 'en_US', 'Content - create form', '', ''),
  (1189, 'fr_FR', 'Contenu - formulaire de création', '', ''),
  (1190, 'en_US', 'Folder - delete form', '', ''),
  (1190, 'fr_FR', 'Dossier - formulaire de suppression', '', ''),
  (1191, 'en_US', 'Content - delete form', '', ''),
  (1191, 'fr_FR', 'Contenu - formulaire de suppression', '', ''),
  (1192, 'en_US', 'Folder - JavaScript', '', ''),
  (1192, 'fr_FR', 'Dossiers - JavaScript', '', ''),
  (1193, 'en_US', 'Template - Edit JavaScript', '', ''),
  (1193, 'fr_FR', 'Gabarit - JavaScript modification', '', ''),
  (1194, 'en_US', 'Tax - Edit JavaScript', '', ''),
  (1194, 'fr_FR', 'Taxe - JavaScript modification', '', ''),
  (1195, 'en_US', 'Hook - Edit JavaScript', '', ''),
  (1195, 'fr_FR', 'Hook - JavaScript modification', '', ''),
  (1196, 'en_US', 'Countries - at the top', '', ''),
  (1196, 'fr_FR', 'Pays - en haut', '', ''),
  (1197, 'en_US', 'Countries - table header', '', ''),
  (1197, 'fr_FR', 'Pays - colonne tableau', '', ''),
  (1198, 'en_US', 'Countries - table row', '', ''),
  (1198, 'fr_FR', 'Pays - ligne tableau', '', ''),
  (1199, 'en_US', 'Countries - bottom', '', ''),
  (1199, 'fr_FR', 'Pays - bas', '', ''),
  (1200, 'en_US', 'Country - create form', '', ''),
  (1200, 'fr_FR', 'Pays - formulaire de création', '', ''),
  (1201, 'en_US', 'Country - delete form', '', ''),
  (1201, 'fr_FR', 'Pays - formulaire de suppression', '', ''),
  (1202, 'en_US', 'Countries - JavaScript', '', ''),
  (1202, 'fr_FR', 'Pays - JavaScript', '', ''),
  (1203, 'en_US', 'Currencies - at the top', '', ''),
  (1203, 'fr_FR', 'Devises - en haut', '', ''),
  (1204, 'en_US', 'Currencies - table header', '', ''),
  (1204, 'fr_FR', 'Devises - colonne tableau', '', ''),
  (1205, 'en_US', 'Currencies - table row', '', ''),
  (1205, 'fr_FR', 'Devises - ligne tableau', '', ''),
  (1206, 'en_US', 'Currencies - bottom', '', ''),
  (1206, 'fr_FR', 'Devises - bas', '', ''),
  (1207, 'en_US', 'Currency - create form', '', ''),
  (1207, 'fr_FR', 'Devise - formulaire de création', '', ''),
  (1208, 'en_US', 'Currency - delete form', '', ''),
  (1208, 'fr_FR', 'Devise - formulaire de suppression', '', ''),
  (1209, 'en_US', 'Currencies - JavaScript', '', ''),
  (1209, 'fr_FR', 'Devises - JavaScript', '', ''),
  (1210, 'en_US', 'Customer - Edit', '', ''),
  (1210, 'fr_FR', 'Client - Modification', '', ''),
  (1211, 'en_US', 'Customer - address create form', '', ''),
  (1211, 'fr_FR', 'Client - formulaire de création d\'adresse', '', ''),
  (1212, 'en_US', 'Customer - address update form', '', ''),
  (1212, 'fr_FR', 'Client - formulaire de modification adresse', '', ''),
  (1213, 'en_US', 'Customer - address delete form', '', ''),
  (1213, 'fr_FR', 'Client - formulaire de suppression adresse', '', ''),
  (1214, 'en_US', 'Customer - Edit JavaScript', '', ''),
  (1214, 'fr_FR', 'Client - JavaScript modification', '', ''),
  (1215, 'en_US', 'Attributes value - table header', '', ''),
  (1215, 'fr_FR', 'Valeur des attributs - colonne tableau', '', ''),
  (1216, 'en_US', 'Attributes value - table row', '', ''),
  (1216, 'fr_FR', 'Valeur des attributs - ligne tableau', '', ''),
  (1217, 'en_US', 'Attribute value - create form', '', ''),
  (1217, 'fr_FR', 'Valeur d\'attribut - formulaire de création', '', ''),
  (1218, 'en_US', 'Attribut - id delete form', '', ''),
  (1218, 'fr_FR', 'Attribut - formulaire de suppression ID', '', ''),
  (1219, 'en_US', 'Attribut - Edit JavaScript', '', ''),
  (1219, 'fr_FR', 'Attribut - JavaScript modification', '', ''),
  (1220, 'en_US', 'Profiles - at the top', '', ''),
  (1220, 'fr_FR', 'Profils - en haut', '', ''),
  (1221, 'en_US', 'Profiles - bottom', '', ''),
  (1221, 'fr_FR', 'Profils - bas', '', ''),
  (1222, 'en_US', 'Profile - create form', '', ''),
  (1222, 'fr_FR', 'Profile - formulaire de création', '', ''),
  (1223, 'en_US', 'Profile - delete form', '', ''),
  (1223, 'fr_FR', 'Profile - formulaire de suppression', '', ''),
  (1224, 'en_US', 'Profiles - JavaScript', '', ''),
  (1224, 'fr_FR', 'Profils - JavaScript', '', ''),
  (1225, 'en_US', 'Country - Edit JavaScript', '', ''),
  (1225, 'fr_FR', 'Pays - JavaScript modification', '', ''),
  (1226, 'en_US', 'Profile - Edit JavaScript', '', ''),
  (1226, 'fr_FR', 'Profile - JavaScript modification', '', ''),
  (1227, 'en_US', 'Variable - Edit JavaScript', '', ''),
  (1227, 'fr_FR', 'Variable - JavaScript modification', '', ''),
  (1228, 'en_US', 'Coupon - update JavaScript', '', ''),
  (1228, 'fr_FR', 'Code promo - JavaScript modification', '', ''),
  (1229, 'en_US', 'Coupon - at the top', '', ''),
  (1229, 'fr_FR', 'Code promo - en haut', '', ''),
  (1230, 'en_US', 'Coupon - list caption', '', ''),
  (1230, 'fr_FR', 'Code promo - légende liste', '', ''),
  (1231, 'en_US', 'Coupon - table header', '', ''),
  (1231, 'fr_FR', 'Code promo - colonne tableau', '', ''),
  (1232, 'en_US', 'Coupon - table row', '', ''),
  (1232, 'fr_FR', 'Code promo - ligne tableau', '', ''),
  (1233, 'en_US', 'Coupon - bottom', '', ''),
  (1233, 'fr_FR', 'Code promo - bas', '', ''),
  (1234, 'en_US', 'Coupon - list JavaScript', '', ''),
  (1234, 'fr_FR', 'Code promo - JavaScript des listes', '', ''),
  (1235, 'en_US', 'Module - configuration', '', ''),
  (1235, 'fr_FR', 'Module - configuration', '', ''),
  (1236, 'en_US', 'Module - configuration JavaScript', '', ''),
  (1236, 'fr_FR', 'Module - JavaScript configuration', '', ''),
  (1237, 'en_US', 'Message - Edit JavaScript', '', ''),
  (1237, 'fr_FR', 'Message - JavaScript modification', '', ''),
  (1238, 'en_US', 'Image - Edit JavaScript', '', ''),
  (1238, 'fr_FR', 'Image - JavaScript modification', '', ''),
  (1239, 'en_US', 'Attributes - at the top', '', ''),
  (1239, 'fr_FR', 'Attributs - en haut', '', ''),
  (1240, 'en_US', 'Attributes - table header', '', ''),
  (1240, 'fr_FR', 'Attributs - colonne tableau', '', ''),
  (1241, 'en_US', 'Attributes - table row', '', ''),
  (1241, 'fr_FR', 'Attributs - ligne tableau', '', ''),
  (1242, 'en_US', 'Attributes - bottom', '', ''),
  (1242, 'fr_FR', 'Attributs - bas', '', ''),
  (1243, 'en_US', 'Attribut - create form', '', ''),
  (1243, 'fr_FR', 'Attribut - formulaire de création', '', ''),
  (1244, 'en_US', 'Attribut - delete form', '', ''),
  (1244, 'fr_FR', 'Attribut - formulaire de suppression', '', ''),
  (1245, 'en_US', 'Attribut - add to all form', '', ''),
  (1245, 'fr_FR', 'Attribut - formulaire ajouter à tous', '', ''),
  (1246, 'en_US', 'Attribut - remove to all form', '', ''),
  (1246, 'fr_FR', 'Attribut - formulaire de suppression multiple', '', ''),
  (1247, 'en_US', 'Attributes - JavaScript', '', ''),
  (1247, 'fr_FR', 'Attributs - JavaScript', '', ''),
  (1248, 'en_US', 'Logs - at the top', '', ''),
  (1248, 'fr_FR', 'Logs - en haut', '', ''),
  (1249, 'en_US', 'Logs - bottom', '', ''),
  (1249, 'fr_FR', 'Logs - bas', '', ''),
  (1250, 'en_US', 'Logs - JavaScript', '', ''),
  (1250, 'fr_FR', 'Logs - JavaScript', '', ''),
  (1251, 'en_US', 'Folder - Edit JavaScript', '', ''),
  (1251, 'fr_FR', 'Dossier - JavaScript modification', '', ''),
  (1252, 'en_US', 'Hooks - at the top', '', ''),
  (1252, 'fr_FR', 'Hooks - en haut', '', ''),
  (1253, 'en_US', 'Hooks - table header', '', ''),
  (1253, 'fr_FR', 'Hooks - colonne tableau', '', ''),
  (1254, 'en_US', 'Hooks - table row', '', ''),
  (1254, 'fr_FR', 'Hooks - ligne tableau', '', ''),
  (1255, 'en_US', 'Hooks - bottom', '', ''),
  (1255, 'fr_FR', 'Hooks - bas', '', ''),
  (1256, 'en_US', 'Hook - create form', '', ''),
  (1256, 'fr_FR', 'Hook - formulaire de création', '', ''),
  (1257, 'en_US', 'Hook - delete form', '', ''),
  (1257, 'fr_FR', 'Hook - formulaire de suppression', '', ''),
  (1258, 'en_US', 'Hooks - JavaScript', '', ''),
  (1258, 'fr_FR', 'Hooks - JavaScript', '', ''),
  (1259, 'en_US', 'Layout - CSS', '', ''),
  (1259, 'fr_FR', 'Mise en page - CSS', '', ''),
  (1260, 'en_US', 'Layout - before topbar', '', ''),
  (1260, 'fr_FR', 'Mise en page - avant la barre de titre', '', ''),
  (1261, 'en_US', 'Layout - inside top bar', '', ''),
  (1261, 'fr_FR', 'Mise en page - dans la barre de titre', '', ''),
  (1262, 'en_US', 'Layout - after top bar', '', ''),
  (1262, 'fr_FR', 'Mise en page - après la barre de titre', '', ''),
  (1263, 'en_US', 'Layout - before top menu', '', ''),
  (1263, 'fr_FR', 'Mise en page - avant le menu haut', '', ''),
  (1264, 'en_US', 'Layout - in top menu items', '', ''),
  (1264, 'fr_FR', 'Mise en page - éléments du menu haut', '', ''),
  (1265, 'en_US', 'Layout - after top menu', '', ''),
  (1265, 'fr_FR', 'Mise en page - après le menu haut', '', ''),
  (1266, 'en_US', 'Layout - before footer', '', ''),
  (1266, 'fr_FR', 'Mise en page - avant le pied', '', ''),
  (1267, 'en_US', 'Layout - in footer', '', ''),
  (1267, 'fr_FR', 'Mise en page - dans le pied', '', ''),
  (1268, 'en_US', 'Layout - after footer', '', ''),
  (1268, 'fr_FR', 'Mise en page - après le pied', '', ''),
  (1269, 'en_US', 'Layout - JavaScript', '', ''),
  (1269, 'fr_FR', 'Mise en page - JavaScript', '', ''),
  (1270, 'en_US', 'Layout - at the top of the top bar', '', ''),
  (1270, 'fr_FR', 'Mise en page - en haut de la barre supérieure', '', ''),
  (1271, 'en_US', 'Layout - at the bottom of the top bar', '', ''),
  (1271, 'fr_FR', 'Mise en page - en bas de la barre supérieure', '', ''),
  (1272, 'en_US', 'Layout - in the menu customers', '', ''),
  (1272, 'fr_FR', 'Mise en page - dans le menu clients', '', ''),
  (1273, 'en_US', 'Layout - in the menu orders', '', ''),
  (1273, 'fr_FR', 'Mise en page - dans le menu commandes', '', ''),
  (1274, 'en_US', 'Layout - in the menu catalog', '', ''),
  (1274, 'fr_FR', 'Mise en page - dans le menu catalogue', '', ''),
  (1275, 'en_US', 'Layout - in the menu folders', '', ''),
  (1275, 'fr_FR', 'Mise en page - dans le menu dossiers', '', ''),
  (1276, 'en_US', 'Layout - in the menu tools', '', ''),
  (1276, 'fr_FR', 'Mise en page - dans le menu outils', '', ''),
  (1277, 'en_US', 'Layout - in the menu modules', '', ''),
  (1277, 'fr_FR', 'Mise en page - dans le menu modules', '', ''),
  (1278, 'en_US', 'Layout - in the menu configuration', '', ''),
  (1278, 'fr_FR', 'Mise en page - dans le menu configuration', '', ''),
  (1279, 'en_US', 'Brand - Edit JavaScript', '', ''),
  (1279, 'fr_FR', 'Marque - JavaScript modification', '', ''),
  (1280, 'en_US', 'Home - block', '', ''),
  (1280, 'fr_FR', 'Accueil - bloc', '', ''),
  (1281, 'en_US', 'Brands - at the top', '', ''),
  (1281, 'fr_FR', 'Marques - en haut', '', ''),
  (1282, 'en_US', 'Brands - table header', '', ''),
  (1282, 'fr_FR', 'Marques - colonne tableau', '', ''),
  (1283, 'en_US', 'Brands - table row', '', ''),
  (1283, 'fr_FR', 'Marques - ligne tableau', '', ''),
  (1284, 'en_US', 'Brands - bottom', '', ''),
  (1284, 'fr_FR', 'Marques - bas', '', ''),
  (1285, 'en_US', 'Brand - create form', '', ''),
  (1285, 'fr_FR', 'Marque - formulaire de création', '', ''),
  (1286, 'en_US', 'Brand - delete form', '', ''),
  (1286, 'fr_FR', 'Marque - formulaire de suppression', '', ''),
  (1287, 'en_US', 'Brand - JavaScript', '', ''),
  (1287, 'fr_FR', 'Marque - JavaScript', '', ''),
  (1288, 'en_US', 'Exports - at the top', '', ''),
  (1288, 'fr_FR', 'Exports - en haut', '', ''),
  (1289, 'en_US', 'Exports - at the bottom of a category', '', ''),
  (1289, 'fr_FR', 'Exports - en bas d''une catégorie', '', ''),
  (1290, 'en_US', 'Exports - at the bottom of column 1', '', ''),
  (1290, 'fr_FR', 'Exports - en bas de la colonne 1', '', ''),
  (1291, 'en_US', 'Exports - JavaScript', '', ''),
  (1291, 'fr_FR', 'Exports - JavaScript', '', ''),
  (1292, 'en_US', 'Export - JavaScript', '', ''),
  (1292, 'fr_FR', 'Export - JavaScript', '', ''),
  (1293, 'en_US', 'Brand - content', '', ''),
  (1293, 'fr_FR', 'Marque - contenu', '', ''),
  (1294, 'en_US', 'Customer - order table header', '', ''),
  (1294, 'fr_FR', 'Client - colonne tableau commande', '', ''),
  (1295, 'en_US', 'Customer - order table row', '', ''),
  (1295, 'fr_FR', 'Client - ligne tableau commande', '', ''),

  (2001, 'fr_FR', 'Facture - CSS', '', ''),
  (2001, 'en_US', 'Invoice - CSS', '', ''),
  (2002, 'fr_FR', 'Facture - dans l\'en-tête', '', ''),
  (2002, 'en_US', 'Invoice - in the header', '', ''),
  (2003, 'fr_FR', 'Facture - en haut du pied de page', '', ''),
  (2003, 'en_US', 'Invoice - at the top of the footer', '', ''),
  (2004, 'fr_FR', 'Facture - mentions légales', '', ''),
  (2004, 'en_US', 'Invoice - imprint', '', ''),
  (2005, 'fr_FR', 'Facture - en bas du pied de page', '', ''),
  (2005, 'en_US', 'Invoice - at the bottom of the footer', '', ''),
  (2006, 'fr_FR', 'Facture - en bas de la zone d\'informations', '', ''),
  (2006, 'en_US', 'Invoice - at the bottom of information area', '', ''),
  (2007, 'fr_FR', 'Facture - après la zone d\'informations', '', ''),
  (2007, 'en_US', 'Invoice - after the information area', '', ''),
  (2008, 'fr_FR', 'Facture - adresse de livraison', '', ''),
  (2008, 'en_US', 'Invoice - delivery address', '', ''),
  (2009, 'fr_FR', 'Facture - après la zone d\'adresses', '', ''),
  (2009, 'en_US', 'Invoice - after addresse area', '', ''),
  (2010, 'fr_FR', 'Facture - après la liste des produits', '', ''),
  (2010, 'en_US', 'Invoice - after product listing', '', ''),
  (2011, 'fr_FR', 'Facture - après le résumé de la commande', '', ''),
  (2011, 'en_US', 'Invoice - after the order summary', '', ''),
  (2012, 'fr_FR', 'Bon de livraison - CSS', '', ''),
  (2012, 'en_US', 'Delivery - CSS', '', ''),
  (2013, 'fr_FR', 'Bon de livraison - dans l\'en-tête', '', ''),
  (2013, 'en_US', 'Delivery - in the header', '', ''),
  (2014, 'fr_FR', 'Bon de livraison - en haut du pied de page', '', ''),
  (2014, 'en_US', 'Delivery - at the top of the footer', '', ''),
  (2015, 'fr_FR', 'Bon de livraison - mentions légales', '', ''),
  (2015, 'en_US', 'Delivery - imprint', '', ''),
  (2016, 'fr_FR', 'Bon de livraison - en bas du pied de page', '', ''),
  (2016, 'en_US', 'Delivery - at the bottom of the footer', '', ''),
  (2017, 'fr_FR', 'Bon de livraison - en bas de la zone d\'informations', '', ''),
  (2017, 'en_US', 'Delivery - at the bottom of information area', '', ''),
  (2018, 'fr_FR', 'Bon de livraison - après la zone d\'informations', '', ''),
  (2018, 'en_US', 'Delivery - after the information area', '', ''),
  (2019, 'fr_FR', 'Bon de livraison - adresse de livraison', '', ''),
  (2019, 'en_US', 'Delivery - delivery address', '', ''),
  (2020, 'fr_FR', 'Bon de livraison - après la zone d\'adresses', '', ''),
  (2020, 'en_US', 'Delivery - after addresse area', '', ''),
  (2021, 'fr_FR', 'Bon de livraison - après le résumé de la commande', '', ''),
  (2021, 'en_US', 'Delivery - after the order summary', '', ''),

  (2022, 'fr_FR', 'Confirmation de commande - après les récapitulatif de commande', '', ''),
  (2022, 'en_US', 'Order confirmation - after the order summary', '', ''),

  (2023, 'fr_FR', 'Partout ou l''éditeur WYSIWYG est nécessaire', '', ''),
  (2023, 'en_US', 'Where the WYSIWYG editor is required', '', '');


# ======================================================================================================================
# Admin resources
# ======================================================================================================================

SELECT @max_id := MAX(`id`) FROM `resource`;

INSERT INTO resource (`id`, `code`, `created_at`, `updated_at`) VALUES
(@max_id+1, 'admin.brand', NOW(), NOW()),
(@max_id+2, 'admin.hook', NOW(), NOW()),
(@max_id+3, 'admin.module-hook', NOW(), NOW()),
(@max_id+4, 'admin.sales', NOW(), NOW())
;

INSERT INTO resource_i18n (`id`, `locale`, `title`) VALUES
  (@max_id+1, 'en_US', 'Brand management'),
  (@max_id+1, 'fr_FR', 'Gestion des marques'),
  (@max_id+2, 'en_US', 'Hooks'),
  (@max_id+2, 'fr_FR', 'Hooks'),
  (@max_id+3, 'en_US', 'Hook positions'),
  (@max_id+3, 'fr_FR', 'Position des hooks'),
  (@max_id+4, 'en_US', 'Sales management'),
  (@max_id+4, 'fr_FR', 'Gestion des promotions')
;

# ======================================================================================================================
# Image / Document visible
# ======================================================================================================================

ALTER TABLE `product_document`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `product_image`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `category_document`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `category_image`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `content_document`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `content_image`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `folder_document`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `folder_image`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `module_image`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;
ALTER TABLE `brand_document`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

ALTER TABLE `brand_image`
  ADD COLUMN `visible` TINYINT DEFAULT 1 NOT NULL
  AFTER `file`
;

-- Add version to customer
ALTER TABLE `customer`
  ADD COLUMN `version` INTEGER DEFAULT 0
;

ALTER TABLE `customer`
  ADD COLUMN `version_created_at` DATETIME
;

ALTER TABLE `customer`
  ADD COLUMN `version_created_by` VARCHAR(100)
;

-- ---------------------------------------------------------------------
-- customer_version
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `customer_version`;

CREATE TABLE `customer_version`
(
    `id` INTEGER NOT NULL,
    `ref` VARCHAR(50),
    `title_id` INTEGER NOT NULL,
    `firstname` VARCHAR(255) NOT NULL,
    `lastname` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255),
    `password` VARCHAR(255),
    `algo` VARCHAR(128),
    `reseller` TINYINT,
    `lang` VARCHAR(10),
    `sponsor` VARCHAR(50),
    `discount` FLOAT,
    `remember_me_token` VARCHAR(255),
    `remember_me_serial` VARCHAR(255),
    `created_at` DATETIME,
    `updated_at` DATETIME,
    `version` INTEGER DEFAULT 0 NOT NULL,
    `version_created_at` DATETIME,
    `version_created_by` VARCHAR(100),
    `order_ids` TEXT,
    `order_versions` TEXT,
    PRIMARY KEY (`id`,`version`),
    CONSTRAINT `customer_version_FK_1`
        FOREIGN KEY (`id`)
        REFERENCES `customer` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';



# ======================================================================================================================
# Order placed notification
# ======================================================================================================================

SELECT @store_email := `value` FROM `config` where name='store_email';

INSERT INTO `config` (`name`, `value`, `secured`, `hidden`, `created_at`, `updated_at`) VALUES
('store_notification_emails',@store_email, 1, 1, NOW(), NOW());

SELECT @max_id := MAX(`id`) FROM `message`;

INSERT INTO `message` (`id`, `name`, `secured`, `text_layout_file_name`, `text_template_file_name`, `html_layout_file_name`, `html_template_file_name`, `created_at`, `updated_at`) VALUES
  (@max_id+1, 'order_notification', NULL, NULL, 'order_notification.txt', NULL, 'order_notification.html', NOW(), NOW()),
  (@max_id+2, 'customer_account_changed', 0, NULL, 'account_changed_by_admin.txt', NULL, 'account_changed_by_admin.html', NOW(), NOW()),
  (@max_id+3, 'customer_account_created', 0, NULL, 'account_created_by_admin.txt', NULL, 'account_created_by_admin.html', NOW(), NOW());

INSERT INTO `message_i18n` (`id`, `locale`, `title`, `subject`, `text_message`, `html_message`) VALUES
  (@max_id+1, 'en_US', 'Message sent to the shop owner when a new order is placed', 'New order {$order_ref} placed on {config key="store_name"}', NULL, NULL),
  (@max_id+1, 'fr_FR', 'Message envoyé au gestionnaire de la boutique lors d''une nouvelle commande.', 'Nouvelle commande {$order_ref} reçue sur {config key="store_name"}', NULL, NULL),
  (@max_id+2, 'en_US', 'Mail sent to the customer when its password or email is changed in the back-office', 'Your account information on {config key="store_name"} has been changed.', NULL, NULL),
  (@max_id+2, 'fr_FR', 'Message envoyé au client lorsque son mot de passe ou son email est changé dans le back-office', 'L''accès à votre compte {config key="store_name"} a changé', NULL, NULL),
  (@max_id+3, 'en_US', 'Mail sent to the customer when its account is created by an administrator in the back-office', 'A {config key="store_name"} account has been created for you', NULL, NULL),
  (@max_id+3, 'fr_FR', 'Mail envoyé au client lorsque son compte est crée depuis le back-office par un administrateur', 'Un compte {config key="store_name"} vient d''être crée pour vous.', NULL, NULL);


# ======================================================================================================================
# Add product_sale_elements_id IN order_product
# ======================================================================================================================

ALTER TABLE  `order_product`
  ADD  `product_sale_elements_id` INT NOT NULL
  AFTER  `product_sale_elements_ref`;


# ======================================================================================================================
# Add Virtual product
# ======================================================================================================================

ALTER TABLE  `product`
  ADD  `virtual` TINYINT DEFAULT 0 NOT NULL
  AFTER  `ref`;

ALTER TABLE  `product_version`
  ADD  `virtual` TINYINT DEFAULT 0 NOT NULL
  AFTER  `ref`;


ALTER TABLE  `order_product`
  ADD  `virtual` TINYINT DEFAULT 0 NOT NULL
  AFTER  `postscriptum`;

ALTER TABLE  `order_product`
  ADD  `virtual_document` VARCHAR(255)
  AFTER  `virtual`;


# ======================================================================================================================
# Add Meta data
# ======================================================================================================================

DROP TABLE IF EXISTS `meta_data`;

CREATE TABLE `meta_data`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `meta_key` VARCHAR(100) NOT NULL,
    `element_key` VARCHAR(100) NOT NULL,
    `element_id` INTEGER NOT NULL,
    `is_serialized` TINYINT(1) NOT NULL,
    `value` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `meta_data_key_element_idx` (`meta_key`, `element_key`, `element_id`)
) ENGINE=InnoDB CHARACTER SET='utf8';


# ======================================================================================================================
# Allow negative stock
# ======================================================================================================================

INSERT INTO `config` (`name`, `value`, `secured`, `hidden`, `created_at`, `updated_at`) VALUES
  ('allow_negative_stock', '0', 0, 0, NOW(), NOW());

SELECT @max_id := MAX(`id`) FROM `config`;

INSERT INTO `config_i18n` (`id`, `locale`, `title`, `description`, `chapo`, `postscriptum`) VALUES
  (@max_id, 'en_US', 'Allow negative product stock (1) or not (0, default)', NULL, NULL, NULL),
  (@max_id, 'fr_FR', 'Autoriser un stock négatif sur les produits (1) ou pas (0, défaut)', NULL, NULL, NULL);

# ======================================================================================================================
# Module configuration
# ======================================================================================================================

-- ---------------------------------------------------------------------
-- module_config
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `module_config`;

CREATE TABLE `module_config`
(
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `module_id` INTEGER NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `created_at` DATETIME,
  `updated_at` DATETIME,
  PRIMARY KEY (`id`),
  INDEX `idx_module_id_name` (`module_id`, `name`),
  CONSTRAINT `fk_module_config_module_id`
  FOREIGN KEY (`module_id`)
  REFERENCES `module` (`id`)
    ON UPDATE RESTRICT
    ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';

-- ---------------------------------------------------------------------
-- module_config_i18n
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `module_config_i18n`;

CREATE TABLE `module_config_i18n`
(
  `id` INTEGER NOT NULL,
  `locale` VARCHAR(5) DEFAULT 'en_US' NOT NULL,
  `value` TEXT,
  PRIMARY KEY (`id`,`locale`),
  CONSTRAINT `module_config_i18n_FK_1`
  FOREIGN KEY (`id`)
  REFERENCES `module_config` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB CHARACTER SET='utf8';

# ======================================================================================================================
# Update of short title Mister
# ======================================================================================================================

-- en_US
UPDATE `customer_title_i18n`
  SET `short` = 'Mr.'
  WHERE `customer_title_i18n`.`id` = 1
    AND `customer_title_i18n`.`locale` = 'en_US';
-- fr_FR
UPDATE `customer_title_i18n`
  SET `short` = 'M.'
  WHERE `customer_title_i18n`.`id` = 1
    AND `customer_title_i18n`.`locale` = 'fr_FR';


# ======================================================================================================================
# End of changes
# ======================================================================================================================

SET FOREIGN_KEY_CHECKS = 1;
