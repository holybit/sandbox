package com.returnpath.poma.selenium;

import java.net.MalformedURLException;
import java.net.URL;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.*;

public class SeleniumExample {
    public static void main(String args[]) throws Exception {
        URL server = new URL("http://localhost:4444/wd/hub/");

        DesiredCapabilities capabilities = new DesiredCapabilities();
        capabilities.setBrowserName("firefox");
        capabilities.setJavascriptEnabled(true);
        WebDriver driver = new RemoteWebDriver(server, capabilities);

        driver.get("http://www.google.com");
        WebElement element = driver.findElement(By.name("q"));
        element.sendKeys("Cheese!");
        element.submit();

        System.out.println("Page title is: " + driver.getTitle());
        
        // Page rendered dynamically with JavaScript
        // Wait for the page to load, timeout after x seconds
        (new WebDriverWait(driver, 2)).until(new ExpectedCondition<Boolean>() {
            public Boolean apply(WebDriver d) {
                return d.getTitle().toLowerCase().startsWith("cheese!");
            }
        });

        System.out.println("Page title is: " + driver.getTitle());
        
        driver.quit();
    }
}
