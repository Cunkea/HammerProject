using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Project.Models;
using System.Text;
using System.Data.SqlClient;

namespace Project.Controllers
{
    public class EmployeesController : Controller
    {
        private CompanyEntities db = new CompanyEntities();

        // GET: Employees
        public async Task<ActionResult> Index()
        {
            var employee = db.Employee.Include(e => e.Department);
            return View(await employee.ToListAsync());
        }

        // GET: Employees/Details/5
        public async Task<ActionResult> Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Employee employee = await db.Employee.FindAsync(id);
            if (employee == null)
            {
                return HttpNotFound();
            }
            return View(employee);
        }

        // GET: Employees/Create
        public ActionResult Create()
        {
            ViewBag.departmentNo = new SelectList(db.Department, "departmentNo", "departmentNo");
            return View();
        }

        // POST: Employees/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Create([Bind(Include = "employeeNo,employeeName,salary,departmentNo,lastModifyDate")] Employee employee)
        {
            if (ModelState.IsValid)
            {
                employee.lastModifyDate = DateTime.Now;
                db.Employee.Add(employee);
                await db.SaveChangesAsync();
                return RedirectToAction("Index");
            }

            ViewBag.departmentNo = new SelectList(db.Department, "departmentNo", "departmentNo", employee.departmentNo);
            return View(employee);
        }

        // GET: Employees/Edit/5
        public async Task<ActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Employee employee = await db.Employee.FindAsync(id);
            if (employee == null)
            {
                return HttpNotFound();
            }
            ViewBag.departmentNo = new SelectList(db.Department, "departmentNo", "departmentNo", employee.departmentNo);
            return View(employee);
        }

        // POST: Employees/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Edit([Bind(Include = "employeeNo,employeeName,salary,departmentNo,lastModifyDate")] Employee employee)
        {
            if (ModelState.IsValid)
            {
                employee.lastModifyDate = DateTime.Now;
                db.Entry(employee).State = EntityState.Modified;
                await db.SaveChangesAsync();
                return RedirectToAction("Index");
            }
            ViewBag.departmentNo = new SelectList(db.Department, "departmentNo", "departmentNo", employee.departmentNo);
            return View(employee);
        }

        // GET: Employees/Delete/5
        public async Task<ActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Employee employee = await db.Employee.FindAsync(id);
            if (employee == null)
            {
                return HttpNotFound();
            }
            return View(employee);
        }

        // POST: Employees/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> DeleteConfirmed(int id)
        {
            Employee employee = await db.Employee.FindAsync(id);
            db.Employee.Remove(employee);
            await db.SaveChangesAsync();
            return RedirectToAction("Index");
        }

        [HttpPost]
        public FileResult Download()
        {
            string[] columnNames = new string[] { "employeeNo", "employeeName        ", "Salary      ", "departmentNo" };

            var employees = from employee in db.Employee
                            select employee;
            
            string txt = string.Empty;
            string line = "+----------+--------------------+------------+------------+";
            txt += line + "\r\n|";
            foreach (string columnName in columnNames)
            {
                txt += columnName + '|';
            }
            
            txt += "\r\n" + line;

            foreach (var employee in employees)
            {
                txt += "\r\n|";
                txt += employee.employeeNo;
                for(int i = 0 ; i < 10 - employee.employeeNo.ToString().Length ; i++)
                {
                    txt += " ";
                }
                txt += "|";
                txt += employee.employeeName;
                for (int i = 0; i < 20 - employee.employeeName.Length; i++)
                {
                    txt += " ";
                }
                txt += "|";
                txt += employee.salary;
                for (int i = 0; i < 12 - employee.salary.ToString().Length; i++)
                {
                    txt += " ";
                }
                txt += "|";
                txt += "    " + employee.departmentNo;
                for (int i = 0; i < 8 - employee.departmentNo.ToString().Length; i++)
                {
                    txt += " ";
                }
                txt += "|\r\n" + line;
            }

            //Download the CSV file.
            byte[] bytes = Encoding.ASCII.GetBytes(txt);
            return File(bytes, "application/text", "Employees.txt");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
